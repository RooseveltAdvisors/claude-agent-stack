# Audit Workflow

> **Trigger:** "audit context files", "analyze CLAUDE.md", "review agent context"

## Prerequisites

Read `ResearchFindings.md` in this skill directory for the scoring criteria.

## Steps

### Step 1: Discover Context Files

Search the repository root and common locations for agent context files:

```
CLAUDE.md, .claude/CLAUDE.md
AGENTS.md
.cursorrules
.github/copilot-instructions.md
.windsurfrules
.clinerules
CONVENTIONS.md
```

Also check for nested CLAUDE.md files in subdirectories (these are scoped context).

Report which files exist and their sizes (word count, line count).

### Step 2: Score Against Anti-Patterns

For each context file found, evaluate against these research-backed anti-patterns. Each anti-pattern detected adds to a "bloat score" (0-100, lower is better):

| Anti-Pattern | Weight | Detection Method |
|---|---|---|
| **Codebase Overview** | +20 | Sections that enumerate directories, describe project structure, or list "key files". Paper found these do NOT help agents navigate faster. |
| **Redundant Documentation** | +15 | Content that duplicates what's in README.md, docs/, or is easily discoverable from package.json/pyproject.toml (e.g., "this project uses React" when package.json has react). |
| **Generic/Boilerplate** | +15 | Content that could apply to any repo: "write clean code", "follow best practices", "use meaningful variable names". |
| **Excessive Style Rules** | +10 | Style/formatting rules that a linter already enforces, or that match language defaults. |
| **Architecture Descriptions** | +10 | Lengthy descriptions of how the system works — agents discover this by reading code. |
| **Non-Actionable Statements** | +10 | Descriptive statements an agent can't act on: "The system is designed for scalability." |
| **Overly Long** | +10 | >500 words total. Paper showed average developer files were 641 words and even that was associated with cost increases. |
| **Marketing/Promotional Language** | +10 | "Best-in-class", "cutting-edge", etc. |

### Step 3: Identify What's Valuable

Flag content that IS worth keeping based on the paper's findings:

| Valuable Pattern | Why It Works |
|---|---|
| **Non-standard tooling** | "Use `bun` not `npm`", "Use `uv` not `pip`" — agents follow these and it changes behavior |
| **Non-obvious test commands** | Specific test invocations not discoverable from config files |
| **Silent-failure gotchas** | Things that break without clear error messages |
| **Required env setup** | Environment variables, services, or config that must exist |
| **Repo-specific conventions** | Naming patterns, file placement rules unique to this project |

### Step 4: Generate Report

Output a structured report:

```
## Context File Audit Report

### Files Found
- [list with word counts]

### Bloat Score: [X]/100
(0 = perfectly minimal, 100 = maximum bloat)

### Anti-Patterns Detected
For each anti-pattern found:
- **[Pattern Name]** (+N points)
  - Line X-Y: "[quoted content]"
  - Recommendation: [specific action]

### Valuable Content Identified
- Line X: "[quoted content]" — Keep (reason)

### Summary
- Words that should be kept: ~N
- Words that should be removed: ~N
- Estimated token savings: ~N tokens
- Estimated cost reduction: ~N%
```
