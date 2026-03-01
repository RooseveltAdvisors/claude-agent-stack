#!/usr/bin/env bash
# deploy.sh — Sync claude-config to ~/.claude on any/all machines
#
# Usage:
#   ./deploy.sh                    # deploy to local only
#   ./deploy.sh local              # deploy to local
#   ./deploy.sh prod               # deploy to production server
#   ./deploy.sh dev                # deploy to development server
#   ./deploy.sh gpu                # deploy to GPU workstation
#   ./deploy.sh all                # deploy to all machines
#
# SETUP: Edit the ssh_target values in deploy_remote() to match your machines.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

deploy_local() {
  echo "==> Deploying to local ~/.claude ..."
  rsync -av \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.DS_Store' \
    --exclude='settings.json' \
    --exclude='settings.local.json' \
    "$REPO_DIR/skills/" ~/.claude/skills/
  rsync -av \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.DS_Store' \
    "$REPO_DIR/hooks/" ~/.claude/hooks/
  rsync -av "$REPO_DIR/agents/" ~/.claude/agents/
  rsync -av "$REPO_DIR/commands/" ~/.claude/commands/
  cp "$REPO_DIR/CLAUDE.md" ~/.claude/CLAUDE.md
  [ -d "$REPO_DIR/PAI/USER" ] && rsync -av "$REPO_DIR/PAI/USER/" ~/.claude/PAI/USER/
  echo "✓ Local deploy done"
}

deploy_remote() {
  local machine="$1"
  local ssh_target
  case "$machine" in
    # Edit these to match your SSH aliases / user@host
    prod)   ssh_target="user@your-prod-server" ;;
    dev)    ssh_target="user@your-dev-server" ;;
    gpu)    ssh_target="user@your-gpu-server" ;;
    *)      echo "Unknown machine: $machine"; exit 1 ;;
  esac

  echo "==> Deploying to $machine ($ssh_target) ..."

  # Ensure target dirs exist
  ssh "$ssh_target" "mkdir -p ~/.claude/{skills,hooks,agents,commands,PAI/USER}"

  rsync -av \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.DS_Store' \
    --exclude='settings.json' \
    --exclude='settings.local.json' \
    -e ssh \
    "$REPO_DIR/skills/" "$ssh_target:~/.claude/skills/"

  rsync -av \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.DS_Store' \
    -e ssh \
    "$REPO_DIR/hooks/" "$ssh_target:~/.claude/hooks/"

  rsync -av -e ssh "$REPO_DIR/agents/" "$ssh_target:~/.claude/agents/"
  rsync -av -e ssh "$REPO_DIR/commands/" "$ssh_target:~/.claude/commands/"
  ssh "$ssh_target" "cat > ~/.claude/CLAUDE.md" < "$REPO_DIR/CLAUDE.md"
  [ -d "$REPO_DIR/PAI/USER" ] && rsync -av -e ssh "$REPO_DIR/PAI/USER/" "$ssh_target:~/.claude/PAI/USER/"

  echo "✓ $machine deploy done"
}

TARGET="${1:-local}"

case "$TARGET" in
  local)  deploy_local ;;
  prod)   deploy_remote prod ;;
  dev)    deploy_remote dev ;;
  gpu)    deploy_remote gpu ;;
  all)
    deploy_local
    deploy_remote prod
    deploy_remote dev
    deploy_remote gpu
    ;;
  *)
    echo "Usage: $0 [local|prod|dev|gpu|all]"
    exit 1
    ;;
esac

echo ""
echo "Deploy complete."
