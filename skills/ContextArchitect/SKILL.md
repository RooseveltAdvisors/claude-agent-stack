---
name: ContextArchitect
description: Audit and optimize agent context files across Claude Code and OpenAI Codex. Covers CLAUDE.md, AGENTS.md, rules, skills, and memory organization. USE WHEN "optimize context" OR "audit setup" OR "context architecture" OR "where should this go" OR "reduce duplication" OR "context budget" OR "too many tokens" OR "reorganize rules" OR "skill hierarchy" OR "CLAUDE.md too big" OR "AGENTS.md too big" OR "optimize skills". Based on Gloaguen et al. 2026 research, Anthropic best practices, and OpenAI Codex docs.
---

# ContextArchitect

Analyzes your entire agent context setup — across both **Claude Code** (`CLAUDE.md`, `.claude/`) and **OpenAI Codex** (`AGENTS.md`, `.codex/`) — at user and project levels. Identifies duplication, bloat, misplaced content, and cross-agent inconsistencies.

## Workflow Routing

| Workflow | Trigger | File |
|----------|---------|------|
| **Audit** | "audit setup", "optimize skills", "check my organization" | `Workflows/Audit.md` |
| **Placement** | "where should this go", "user or project level" | `Workflows/Placement.md` |

## Context Files

- `Principles.md` — Research-backed principles (Gloaguen paper, Anthropic docs, OpenAI Codex docs, community patterns)

## Examples

**Example 1: Full audit**
```
User: "audit my skill setup"
-> Scans ~/.claude/, ~/.codex/, and project-level files
-> Checks for duplication, bloat, misplaced content, cross-agent drift
-> Outputs prioritized recommendations with exact file moves
```

**Example 2: Placement decision**
```
User: "I have a code review workflow -- where should it live?"
-> Asks: project-specific rules? Used across all repos? Which agents?
-> Recommends user-level skill vs project-level rule
-> Shows exact directory path and template
```

**Example 3: Cross-agent consistency check**
```
User: "are my Claude and Codex configs in sync?"
-> Compares ~/.claude/CLAUDE.md with ~/.codex/AGENTS.md
-> Flags drift between the two
-> Recommends single source of truth pattern (stow-managed)
```
