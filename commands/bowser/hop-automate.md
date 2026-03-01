---
model: opus
description: Run a saved browser automation workflow with configurable skill, mode, and vision settings
argument-hint: <workflow-name> [prompt] [playwright|claude] [headed|headless] [vision]
---

# Hop Automate

Run a saved browser automation workflow from `.claude/commands/bowser/` with configurable skill and mode overrides.

## Variables

Parse `$ARGUMENTS` to extract:

- **WORKFLOW:** $1 (required) — name of the workflow file (without `.md`)
- **SKILL:** keyword detection — `playwright-bowser` (default) or `claude-bowser` (use with `--chrome` flag)
- **MODE:** keyword detection — `headed` (default) or `headless`
- **VISION:** keyword detection — `false` (default), `true` if `vision` keyword present
- **PROMPT:** all remaining non-keyword text after WORKFLOW

**Keyword detection rules (case-insensitive):**
- `claude` → SKILL = `claude-bowser`
- `playwright` → SKILL = `playwright-bowser`
- `headless` → MODE = `headless`
- `headed` → MODE = `headed`
- `vision` → VISION = `true`
- Everything else after WORKFLOW → PROMPT

## Workflow

### Phase 1: Parse and Validate

1. If no `$ARGUMENTS`, list all available workflows in `.claude/commands/bowser/` (excluding `hop-automate.md`) and stop.
2. Extract WORKFLOW from first argument.
3. Use Glob to check `.claude/commands/bowser/{WORKFLOW}.md` exists. If not, list available workflows and stop.
4. Parse remaining arguments for keywords; collect leftover text as PROMPT.

### Phase 2: Load Workflow

5. Read `.claude/commands/bowser/{WORKFLOW}.md`.
6. Check frontmatter for `defaults:` — use as base values. CLI keyword overrides take priority.
7. Extract workflow content (everything after frontmatter `---`).

### Phase 3: Execute

8. Execute the resolved skill (`/playwright-bowser` or `/claude-bowser`) with:

```
(headed: {MODE}) (vision: {VISION})

{workflow content with {PROMPT} substituted}
```

### Phase 4: Report

9. Report: which workflow ran, which skill/mode was used, and the results.
