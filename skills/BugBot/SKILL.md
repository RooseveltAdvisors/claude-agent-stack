---
name: BugBot
description: Adversarial iterative code review that loops until clean. USE WHEN user says "bugbot", "deep review", "adversarial review", "find all bugs", "review until clean", OR wants iterative bug hunting with test coverage.
---

# BugBot

Adversarial iterative code review powered by a Ralph Wiggum loop. Attacks code from every angle — finds bug, scores confidence, fixes it, writes regression test, repeats until a full pass finds nothing new.

Unlike single-pass code review (static pattern scan), BugBot **loops automatically** until ALL_CLEAN: zero CRITICAL/HIGH findings, all 7 ODC triggers covered, all tests passing.

## Customization for Your Repo

BugBot is intentionally generic. To tailor it for a specific project, create a **repo-level override** at `.claude/skills/BugBot/Overrides.md` with:

- **Lint commands** — What linter/formatter to run in the mechanical pre-pass (default: detect from project)
- **Test commands** — How to run your test suite (default: detect from project)
- **Extra attack angles** — Repo-specific angles beyond the generic catalog (e.g., "HIPAA compliance" for healthcare, "i18n coverage" for multi-language apps)
- **Excluded paths** — Files/dirs to skip (e.g., generated code, vendored deps)
- **Severity overrides** — Promote certain bug classes to higher severity (e.g., "any auth bypass is always S3")

If no overrides file exists, BugBot uses sensible defaults and auto-detects the project's toolchain.

## Execution — Automatic Loop Until ALL_CLEAN

When `/BugBot` is invoked:

### 1. Determine Review Target

- If the user specified files or a feature name, use those
- Otherwise, run `git diff --name-only HEAD~4` to find recently changed files
- Read the diff and write a short target description

### 2. Check for ralph-wiggum Plugin

Verify `/ralph-wiggum:ralph-loop` is in the available skills list.

**If NOT available**, tell the user:
> BugBot requires the `ralph-wiggum` plugin. Install it:
> ```
> claude plugins add ralph-wiggum
> ```
> Then restart Claude Code and re-run `/BugBot`.

### 3. Detect Project Toolchain

Auto-detect the project's language, linter, formatter, and test runner by checking for common config files:

| File | Detected Stack |
|------|---------------|
| `pyproject.toml`, `setup.py`, `requirements.txt` | Python (ruff, black/ruff-format, pytest) |
| `package.json` | Node.js (eslint, prettier, jest/vitest/mocha) |
| `Cargo.toml` | Rust (clippy, rustfmt, cargo test) |
| `go.mod` | Go (golangci-lint, gofmt, go test) |
| `tsconfig.json` | TypeScript (tsc --noEmit, eslint, jest/vitest) |

Store the detected commands for use in the mechanical pre-pass. If a repo-level `Overrides.md` exists, use its commands instead.

### 4. Generate State File with Unique ID

Each BugBot invocation gets its own state file to support parallel sessions. Generate an 8-character random hex ID (e.g., via `openssl rand -hex 4`) and use it as the state file name:

```
.claude/review-state-{ID}.md
```

Example: `.claude/review-state-a3f1b20c.md`

Create the state file fresh. Tell the user the state file path so they can track progress.

### 5. Check for Repo Overrides

Read `.claude/skills/BugBot/Overrides.md` if it exists. Incorporate any custom lint/test commands, extra attack angles, excluded paths, or severity overrides into the loop prompt.

### 6. Launch the Loop

**IMPORTANT — single-line args format.** The ralph-loop skill parses its args as a shell-style string. Multi-line prompts get mangled. Always pass the prompt as a **single line** with the args.

Invoke the Skill tool with:
- `skill`: `ralph-wiggum:ralph-loop`
- `args`: A single-line string in this format (substitute `{TARGET}`, `{CHANGED_FILES}`, `{STATE_FILE}`, and `{OVERRIDES}` with actual values):

```
--max-iterations 10 --completion-promise "ALL_CLEAN" Read the BugBot AdversarialReview workflow at .claude/skills/BugBot/Workflows/AdversarialReview.md (user-level skill at ~/.claude/skills/BugBot/Workflows/AdversarialReview.md) and follow its instructions exactly for ONE iteration. STATE FILE: {STATE_FILE}. TARGET: {TARGET}. CHANGED FILES: {CHANGED_FILES}. OVERRIDES: {OVERRIDES or "none"}. You are inside a Ralph Wiggum loop. Each iteration you get a FRESH context. Your memory across iterations is {STATE_FILE} and files on disk (including git history). Execute ONE iteration: (1) Read {STATE_FILE}, (2) Run mechanical pre-pass, (3) Pick 3-5 UNTRIED attack angles prioritizing uncovered ODC triggers, (4) Spawn parallel review agents, (5) Fix CRITICAL/HIGH bugs and update state in {STATE_FILE}, (6) Check completion. Output the promise ONLY when a full pass of 3+ agents finds ZERO CRITICAL/HIGH, all 7 ODC triggers are covered, and all tests pass.
```

The loop terminates on `<promise>ALL_CLEAN</promise>` or after 10 iterations (safety limit).

## Workflow Routing

| Workflow | Trigger | File |
|----------|---------|------|
| **AdversarialReview** | "bugbot", "deep review", "adversarial review", "review until clean", "find all bugs" | `Workflows/AdversarialReview.md` |

Full methodology — confidence scoring, evidence requirements, attack angle catalog, agent templates, ODC trigger tracking, state file format — is in `Workflows/AdversarialReview.md`.

## Examples

```
/BugBot                                    → review recent git changes
/BugBot deep review src/auth.py            → scope to specific files
/BugBot review the checkout feature        → scope to a feature
```

Detailed examples with full iteration traces: `Examples.md`
