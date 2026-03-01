# BugBot Examples

## Example 1: Review Recent Changes (Default)

```
User: "/BugBot"

→ Detects changed files via git diff HEAD~4
→ Auto-detects toolchain (e.g., Python/ruff/pytest from pyproject.toml)
→ Launches ralph-wiggum loop with AdversarialReview prompt
→ Loop iterates automatically:

  Iteration 1:
    - Mechanical pre-pass: ruff clean, 0 issues
    - Angles: adjacent feature mutation, round-trip consistency, NULL/empty/missing
    - 3 parallel agents with shuffled file order
    - Findings: 2 HIGH bugs (json.loads non-list, unnormalized comparison)
    - Fixes applied, regression tests written, state file updated
    - Promise NOT output (bugs found)

  Iteration 2:
    - Reads state file, picks untried angles
    - Angles: stale state, response shape, optimistic UI
    - 3 parallel agents
    - Findings: 0 CRITICAL/HIGH
    - ODC coverage: 5/7 triggers covered
    - Promise NOT output (missing Error recovery, Configuration triggers)

  Iteration 3:
    - Angles: error path UX, authorization, CSRF
    - 3 parallel agents
    - Findings: 0 CRITICAL/HIGH
    - ODC coverage: 7/7 triggers covered, 15+ angles completed
    - All tests pass
    - Outputs <promise>ALL_CLEAN</promise>
    - Loop exits

→ Total: 3 iterations, 2 bugs fixed, 2 regression tests added
```

## Example 2: Scoped to Specific Files

```
User: "/BugBot deep review src/auth/handler.py and src/middleware/rbac.py"

→ TARGET: "auth handler and RBAC middleware"
→ CHANGED_FILES: src/auth/handler.py, src/middleware/rbac.py
→ Launches ralph-wiggum loop scoped to those files
→ Each iteration's agents focus only on those files + their callers
→ Cross-references all callers of modified functions
→ Loops until ALL_CLEAN
```

## Example 3: Feature-Scoped Review

```
User: "/BugBot review the user registration feature"

→ TARGET: "User registration feature"
→ Identifies files via git diff + grep for "register" / "signup" / "onboard"
→ CHANGED_FILES: src/handlers/register.py, src/models/user.py,
    src/components/RegisterForm.tsx, etc.
→ Launches ralph-wiggum loop
→ Agents trace the full registration pipeline:
    input → validate → create user → send email → redirect
→ Loops until ALL_CLEAN
```

## Example 4: What a Single Iteration Looks Like

Each ralph-loop iteration follows this flow:

```
1. READ STATE
   → .claude/review-state-a3f1b20c.md shows:
     - Iteration 2
     - Angles completed: 1, 3, 5, 6, 9
     - Triggers covered: Simple, Complex, Boundary, Interaction
     - Missing triggers: Error recovery, Stress/volume, Configuration

2. MECHANICAL PRE-PASS
   → ruff check src/handlers/user.py src/models/user.py
   → 0 issues (or fix trivial issues first)

3. PICK ANGLES (prioritize uncovered triggers)
   → Angle 11: Error path UX (covers Error recovery)
   → Angle 14: Authorization (covers Configuration)
   → Angle 23: Rapid interaction (covers Stress/volume)

4. SPAWN 3 PARALLEL AGENTS
   Agent A (Error path UX):
     Files: user.py → handler.py → UserProfile.tsx
     Verdict: CLEAN

   Agent B (Authorization):
     Files: handler.py → UserProfile.tsx → user.py
     Verdict: BUG FOUND [S2 x C2 = MEDIUM]
       Location: src/handlers/user.py:142
       Issue: viewer role can modify profile fields
       M/W/U: MISSING — no role check on PUT endpoint

   Agent C (Rapid interaction):
     Files: UserProfile.tsx → handler.py → user.py
     Verdict: CLEAN

5. PROCESS RESULTS
   → 0 CRITICAL/HIGH findings (MEDIUM doesn't block)
   → Fix MEDIUM if budget allows
   → Update state file with angles 11, 14, 23

6. CHECK COMPLETION
   → All 7 ODC triggers now covered ✓
   → 15+ angles completed ✓
   → Zero CRITICAL/HIGH ✓
   → Run tests: pytest → all pass ✓
   → Output <promise>ALL_CLEAN</promise>
```

## Example 5: Using Repo Overrides

If your project has `.claude/skills/BugBot/Overrides.md`:

```markdown
## Lint Commands
- `cargo clippy -- -D warnings`
- `cargo fmt --check`

## Test Commands
- `cargo test --all`

## Extra Attack Angles
29. **Unsafe blocks** — Are unsafe blocks justified? Could they be replaced with safe alternatives?
30. **Lifetime issues** — Are borrowed references valid for their entire usage scope?

## Severity Overrides
- Any memory safety issue: always S3 (Critical)
- Any use-after-free pattern: always S3 (Critical)

## Excluded Paths
- `target/`
- `benches/`
```

The mechanical pre-pass will use `cargo clippy` and `cargo fmt`, tests will run `cargo test`, and agents will include the Rust-specific angles alongside the generic catalog.

## Confidence Scoring in Action

```
Agent finds: json.loads could return a dict instead of a list

Scoring:
  Severity: S2 (Moderate) — incorrect behavior, could show wrong data
  Confidence: C3 (Confirmed) — json.loads('{"key": "val"}') returns dict, not list

  S2 x C3 = HIGH → blocks ALL_CLEAN, must fix

Evidence:
  Location: src/utils/formatter.py:653
  Code: items = json.loads(row["data_field"])
  Issue: json.loads can return dict/str/int, not just list
  Fix: isinstance check with fallback to empty list

Consensus:
  Agent A flagged it (data round-trip angle)
  Agent C also flagged it (NULL/empty/missing angle)
  → 2 agents independently = auto-upgrade C2→C3 (but was already C3)
```
