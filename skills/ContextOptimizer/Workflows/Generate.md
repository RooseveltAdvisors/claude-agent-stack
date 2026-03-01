# Generate Workflow

> **Trigger:** "generate context file", "create CLAUDE.md from scratch", "init agents.md"

## Prerequisites

Read `ResearchFindings.md` in this skill directory for generation principles.

## Key Principle

> "Unnecessary requirements from context files make tasks harder."
> — Gloaguen et al., 2025

The paper showed LLM-generated context files **decrease** performance by ~3% on average. The primary failure mode: LLMs generate comprehensive overviews that are redundant with existing docs. This workflow intentionally avoids that trap by generating **only what can't be discovered** from the codebase.

## Steps

### Step 1: Explore the Repository

Gather information about the repo — but DO NOT put most of this into the context file. This step is for YOUR understanding, not for output.

1. Read README.md (so you know what's already documented)
2. Check build/config files: package.json, pyproject.toml, Cargo.toml, go.mod, Makefile, Justfile, docker-compose.yml
3. Check for linter/formatter configs: .eslintrc, .prettierrc, ruff.toml, .editorconfig
4. Check for CI: .github/workflows/, .gitlab-ci.yml
5. Run `ls` on root to understand top-level structure
6. Check for existing test patterns: how tests are organized and run

### Step 2: Identify Non-Discoverable Requirements

For each category, only include content if it meets ALL criteria:
- Not in README
- Not in config files
- Not inferable from standard conventions
- Would cause silent failure or wasted effort if unknown

**Categories to evaluate:**

| Category | Include IF... | Example |
|---|---|---|
| **Package manager** | Non-default for the ecosystem | "Use bun, not npm" (JS) or "Use uv, not pip" (Python) |
| **Runtime** | Non-standard | "Use Bun runtime, not Node" |
| **Test command** | Not standard (`npm test`, `pytest`) | "Run `bun test --bail -- src/` for unit tests" |
| **Build command** | Non-obvious | "Build with `make proto` before `cargo build`" |
| **Env requirements** | Required but not in .env.example | "Requires REDIS_URL env var for integration tests" |
| **Gotchas** | Known pitfalls that waste time | "Hairpin NAT: can't curl public IP from LAN, use --resolve" |
| **Naming conventions** | Project-specific, not language-standard | "All API routes use kebab-case, not camelCase" |
| **File placement** | Non-obvious conventions | "New API endpoints go in src/routes/, not src/api/" |
| **Forbidden patterns** | Things that look right but break | "Never import from @internal/* in test files" |

### Step 3: Draft the Minimal File

Use this template — sections with no content get omitted entirely:

```markdown
# [Project Name]

## Critical Constraints
<!-- Only if there are genuine gotchas -->

## Tooling
<!-- Only if non-standard -->

## Testing
<!-- Only if test invocation is non-obvious -->

## Conventions
<!-- Only if not enforced by linter and not standard for the language -->
```

**Hard constraints on the generated file:**
- Maximum 300 words (paper showed even 641-word developer files increased costs)
- Zero codebase overview content (paper proved ineffective)
- Zero architecture description (agents discover by reading code)
- Every line must be imperative and actionable
- If you can't find anything non-discoverable, generate an EMPTY file or no file at all — this is a valid outcome per the research

### Step 4: Validate Against the Paper's Criteria

Before presenting to the user, self-check:

1. **Redundancy check**: For each line, can the agent learn this from README/configs? If yes → delete it.
2. **Actionability check**: Does each line tell the agent to DO something? If just descriptive → delete it.
3. **Silent-failure check**: Would ignoring this line cause a hard-to-debug problem? If the error is obvious → delete it.
4. **Breadth check**: Does this apply to most tasks? If niche → delete or note it's scoped.

### Step 5: Present to User

```
## Generated Context File

### What I found in the repo:
- [Brief summary of repo structure, build system, etc.]

### What I'm INCLUDING (and why):
| Content | Reason |
|---|---|
| "Use bun, not npm" | Non-standard package manager, not in README |

### What I'm deliberately EXCLUDING (and why):
| Content | Reason |
|---|---|
| Project overview | Paper proved overviews don't help agents navigate faster |
| Architecture | Agents discover this by reading code |
| "Uses TypeScript" | Discoverable from tsconfig.json |

### Proposed File
[Show content]

### Word count: N/300
```

### Step 6: Write File

After user approval, write the file. Suggest the appropriate filename:
- For Claude Code: `CLAUDE.md` at repo root
- For Codex/generic: `AGENTS.md` at repo root
- For Cursor: `.cursorrules` at repo root
- For Copilot: `.github/copilot-instructions.md`

Note: content should be the same regardless of filename — the research showed no significant difference between generation prompts.
