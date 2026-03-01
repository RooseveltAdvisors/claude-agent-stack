# Optimize Workflow

> **Trigger:** "optimize context files", "improve CLAUDE.md", "slim down agents.md", "reduce context bloat"

## Prerequisites

- Read `ResearchFindings.md` in this skill directory for optimization principles.
- Run the Audit workflow first (or inline audit if user wants a single pass).

## Steps

### Step 1: Read Current State

1. Read all context files in the repo (CLAUDE.md, AGENTS.md, etc.)
2. Read README.md and check for pyproject.toml / package.json / Makefile / Justfile
3. Identify what's discoverable from standard files vs. what's unique context

### Step 2: Apply the Inclusion Filter

For every line/section in the context file, apply the 4-question filter from the paper:

1. **Is it non-discoverable?** Could an agent learn this by reading README, config files, or running `--help`? If discoverable → REMOVE.
2. **Is it actionable?** Does it tell the agent to DO something specific? If just descriptive → REMOVE.
3. **Does it prevent silent failure?** Would getting it wrong cause a hard-to-debug issue? If the error would be obvious → REMOVE.
4. **Does it apply broadly?** Is this relevant to most tasks in the repo? If it's niche → REMOVE (or move to a scoped subdirectory CLAUDE.md).

### Step 3: Restructure the File

Organize remaining content into this research-backed structure (ordered by impact):

```markdown
# [Project Name]

## Critical Constraints
<!-- Things that cause silent failures if ignored -->

## Tooling
<!-- Non-standard tools: package managers, runtimes, build commands -->

## Testing
<!-- How to run tests if non-obvious -->

## Conventions
<!-- Project-specific patterns the agent must follow -->
<!-- ONLY include if not enforceable by linter/formatter -->
```

**Rules for the optimized file:**
- **No codebase overview section** — paper proved these are ineffective
- **No architecture description** — agents discover this by reading code
- **No generic advice** — "write clean code" helps nothing
- **No redundancy with README** — if it's in the README, don't repeat it
- **Target: under 300 words** — every word costs tokens and the paper showed diminishing/negative returns
- **Imperative voice only** — "Use X" not "The project uses X"
- **Specific over general** — "Run `bun test --bail`" not "Run the tests"

### Step 4: Present the Diff

Show the user a clear before/after comparison:

```
## Optimization Results

### Before
- File: CLAUDE.md
- Words: N
- Estimated tokens: ~N

### After
- Words: N (reduced by X%)
- Estimated tokens: ~N (saving ~X%)

### Removed Content (with reasons)
| Section/Line | Reason | Category |
|---|---|---|
| "Project overview..." | Codebase overview — proven ineffective | Anti-pattern |
| "Use meaningful names" | Generic — applies to any repo | Boilerplate |

### Preserved Content
| Section/Line | Reason |
|---|---|
| "Use bun, never npm" | Non-standard tooling — agents follow this |

### Proposed Optimized File
[Show full optimized content]
```

### Step 5: Apply Changes

After user approval:
1. Write the optimized file
2. If multiple context files exist with overlap, suggest consolidation
3. If content is scoped to a subdirectory, suggest moving to a scoped CLAUDE.md

### Step 6: Post-Optimization Checklist

Verify the optimized file passes:
- [ ] Under 300 words
- [ ] No codebase overview / architecture description
- [ ] No content duplicated from README or config files
- [ ] Every line passes the 4-question inclusion filter
- [ ] Imperative voice throughout
- [ ] Specific commands, not generic advice
- [ ] No marketing/promotional language
