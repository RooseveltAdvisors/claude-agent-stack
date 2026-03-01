# pai-claude-config

> A personal Claude Code configuration system — version-controlled, multi-machine, and extensible. Built on top of [Personal AI Infrastructure (PAI)](https://github.com/danielmiessler/Personal_AI_Infrastructure) by Daniel Miessler.

This repo is the single source of truth for everything in `~/.claude` across all my machines. Skills, hooks, agents, and `CLAUDE.md` are all managed here, versioned in git, and deployed via `deploy.sh`.

Read the companion blog posts:
- [Version-Controlling Your AI's Brain](https://jonroosevelt.com/blog/git-driven-ai-config)
- [PAI: The Operating System I Built Around My AI Assistant](https://jonroosevelt.com/blog/personal-ai-infrastructure)

---

## What This Is

[Claude Code](https://claude.ai/download) reads `~/.claude/CLAUDE.md` as your global system prompt and loads skills from `~/.claude/skills/`. Left unmanaged, these files drift between machines, get lost, or become inconsistent.

This repo solves that by treating `~/.claude` as a **deploy target**, not an edit location. All changes happen here, in git. `deploy.sh` pushes them out.

```
claude-config/
├── CLAUDE.md          # Global system prompt (edit here, not in ~/.claude)
├── deploy.sh          # Rsync to local and remote machines
├── skills/            # User-level skills (available in every project)
├── hooks/             # Lifecycle hooks
├── agents/            # Subagent definitions
└── commands/          # Slash commands
```

---

## Quick Start

### 1. Fork or clone this repo

```bash
git clone https://github.com/JonRoosevelt/pai-claude-config ~/git/claude-config
cd ~/git/claude-config
```

### 2. Customize `CLAUDE.md`

Edit `CLAUDE.md` to match your stack, machines, and preferences. Replace the placeholder machine table with your own SSH aliases.

### 3. Deploy to local machine

```bash
./deploy.sh local
```

This rsyncs everything into `~/.claude/`.

### 4. Deploy to remote machines

Edit `deploy.sh` to add your SSH aliases, then:

```bash
./deploy.sh prod    # deploy to production server
./deploy.sh dev     # deploy to development server
./deploy.sh all     # deploy everywhere
```

### 5. Set up GitHub Actions for auto-deploy

Add a self-hosted GitHub Actions runner on each remote machine. On every push to `main`, CI runs checks and the runner deploys to its own `~/.claude`.

---

## Skills

User-level skills are markdown files that Claude Code loads as extended context. They're available in every project, on every machine.

| Skill | Purpose |
|-------|---------|
| [BugBot](skills/BugBot/) | Adversarial iterative code review — loops until clean |
| [DevFlow](skills/DevFlow/) | CI/CD guardrail — detects your dev stage, blocks deviations |
| [BlogWriter](skills/BlogWriter/) | Write and publish blog posts to Docusaurus sites |
| [Art](skills/Art/) | Hero images and diagrams with Excalidraw aesthetic |
| [Research](skills/Research/) | Multi-agent parallel research with Fabric patterns |
| [Thinking](skills/Thinking/) | First principles, red teaming, council debates |
| [Agents](skills/Agents/) | Dynamic agent composition and management |
| [gcc](skills/gcc/) | Agent-driven memory via GCC commands |
| [CodeReview](skills/CodeReview/) | Anti-pattern detection and security scanning |
| [DevFlow](skills/DevFlow/) | CI/CD pipeline enforcer |
| [Security](skills/Security/) | Network recon, web app testing, OSINT |
| [Utilities](skills/Utilities/) | CLI generation, audio editing, Cloudflare infra |

Browse the full list in [skills/](skills/).

---

## How It Works

### Deploy mechanism

`deploy.sh` uses `rsync` to copy:
- `skills/` → `~/.claude/skills/`
- `hooks/` → `~/.claude/hooks/`
- `agents/` → `~/.claude/agents/`
- `commands/` → `~/.claude/commands/`
- `CLAUDE.md` → `~/.claude/CLAUDE.md`

### What stays out of git

Secrets and ephemeral state never enter version control:

```
settings.json       # API keys
settings.local.json # Local overrides
history.jsonl       # Session history
projects/           # Project state
cache/              # Runtime caches
```

See `.gitignore` for the full list.

### Remote auto-deploy via GitHub Actions

Each remote machine runs a self-hosted GitHub Actions runner. On push to `main`:

1. CI runs checks (secret scanning, shell linting, skill structure validation)
2. Each runner deploys to its own `~/.claude` on the machine it runs on

Local machine runs `./deploy.sh local` manually (no persistent runner).

---

## Based On

- **[Personal AI Infrastructure (PAI)](https://github.com/danielmiessler/Personal_AI_Infrastructure)** by Daniel Miessler — the foundational framework for operating modes (NATIVE/ALGORITHM), skill system design, and CLAUDE.md structure. This repo extends PAI with a git-based deployment layer and custom skills.
- **[Claude Code](https://claude.ai/download)** by Anthropic — the AI coding assistant this config powers.
- **[GitHub Actions](https://docs.github.com/en/actions)** — CI/CD for the auto-deploy pipeline.
- **[CodeRabbit](https://coderabbit.ai)** — automated PR review integrated with DevFlow.

---

## License

MIT — use freely, customize for your own setup.
