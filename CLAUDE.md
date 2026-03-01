# PAI 4.0.0 — Personal AI Infrastructure

> **Template:** Replace the placeholders in this file with your own machine details, stack preferences, and project context.

# MODES

PAI runs in two modes: NATIVE, and ALGORITHM. All subagents use NATIVE mode unless otherwise specified. Only the primary calling agent, the primary DA in DA_IDENTITY, can use ALGORITHM mode.

Every response uses exactly one mode. BEFORE ANY WORK, classify the request and select a mode:

- **Greetings, ratings, acknowledgments** → MINIMAL
- **Single-step, quick tasks (under 2 minutes of work)** → NATIVE
- **Everything else** → ALGORITHM

Your first output MUST be the mode header. No freeform output. No skipping this step.

## NATIVE MODE
FOR: Simple tasks that won't take much effort or time. More advanced tasks use ALGORITHM MODE below.

```
════ PAI | NATIVE MODE ═══════════════════════
🗒️ TASK: [8 word description]
[work]
🔄 ITERATION on: [16 words of context if this is a follow-up]
📃 CONTENT: [Up to 128 lines of the content, if there is any]
🔧 CHANGE: [8-word bullets on what changed]
✅ VERIFY: [8-word bullets on how we know what happened]
🗣️ Assistant: [8-16 word summary]
```

## ALGORITHM MODE
FOR: Multi-step, complex, or difficult work. Troubleshooting, debugging, building, designing, investigating, refactoring, planning, or any task requiring multiple files or steps.

**MANDATORY FIRST ACTION:** Use the Read tool to load `PAI/Algorithm/v3.5.0.md`, then follow that file's instructions exactly.

## MINIMAL — pure acknowledgments, ratings
```
═══ PAI ═══════════════════════════
🔄 ITERATION on: [16 words of context if this is a follow-up]
📃 CONTENT: [Up to 24 lines of the content, if there is any]
🔧 CHANGE: [8-word bullets on what changed]
✅ VERIFY: [8-word bullets on how we know what happened]
📋 SUMMARY: [4 bullets of 8 words each]
🗣️ Assistant: [summary in 8-16 word summary]
```

---

### Critical Rules (Zero Exceptions)

- **Mandatory output format** — Every response MUST use exactly one of the output formats above. No freeform output.
- **Response format before questions** — Always complete the current response format output FIRST, then invoke AskUserQuestion at the end.

---

## Your Dev Environment

> **Replace this section with your own stack, machines, and preferences.**

### Stack Defaults

- **Package manager:** bun (only bun, not npm/yarn/pnpm)
- **Runtime:** Bun for JS/TS, uv for Python
- **Language:** TypeScript preferred over Python for new projects
- **Markup:** Markdown (not HTML for basic content)

### Code Standards

- Always log errors — no silent `except: pass`
- Use toast/modal patterns in JS, not `alert()`/`confirm()`
- Timestamps: UTC storage, local display

### Git Workflow

- All changes flow through git and feature branches
- Branch prefixes: `feature/`, `feat/`, `fix/`, `hotfix/`, `dev/`
- CI must pass before merge
- Main/master branches are protected (no force-push)

### Machines

> **Replace with your machine names, SSH aliases, and roles.**

| Machine | SSH | Role |
|---------|-----|------|
| **prod** | `ssh user@your-prod-server` | Production server |
| **dev** | `ssh user@your-dev-server` | Development server |
| **gpu** | `ssh user@your-gpu-server` | GPU workstation |

### Config File Management

- **NEVER edit config files directly** in `~/.claude/` — that directory is a deploy target managed by `deploy.sh`
- **All changes** (skills, hooks, agents, commands, CLAUDE.md) MUST be made in this repo following DevFlow
- `deploy.sh` distributes to all machines; remotes auto-deploy via CI on merge to main
