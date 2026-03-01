# CheckAndAdvance Workflow

When invoked, run ALL diagnostic commands, determine the current stage, check for deviations, and guide the user to the next step.

## Step 0: Detect Project Context

Before gathering state, detect the project's conventions dynamically:

```bash
# Detect main branch name (never assume main vs master)
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
[ -z "$MAIN_BRANCH" ] && MAIN_BRANCH=$(git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}')
[ -z "$MAIN_BRANCH" ] && MAIN_BRANCH="main"  # last resort fallback
echo "Main branch: $MAIN_BRANCH"

# Detect repo name and org
REMOTE_URL=$(git remote get-url origin 2>/dev/null)
GH_REPO=$(echo "$REMOTE_URL" | sed -E 's#.*(github|gitlab)\.com[:/](.*)\.git$#\2#; s#.*(github|gitlab)\.com[:/](.*)$#\2#')
echo "Repo: $GH_REPO"

# Detect if this is a production machine
IS_PROD=false
PROD_HOSTS=$(grep -i 'prod hosts:' CLAUDE.md .claude/CLAUDE.md 2>/dev/null | head -1 | sed 's/.*Prod hosts:\s*//' | tr -d '*')
if [ -n "$PROD_HOSTS" ]; then
  echo "$PROD_HOSTS" | tr ',' '\n' | while read host; do
    [ "$(hostname)" = "$(echo "$host" | xargs)" ] && IS_PROD=true
  done
fi
```

Use `$MAIN_BRANCH` everywhere below instead of hardcoded branch names.

## Step 1: Gather State (run ALL in parallel)

```bash
# 1. Current branch
git branch --show-current

# 2. Working tree status
git status --short

# 3. Ahead/behind remote
git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null || echo "no-upstream"

# 4. Recent commits on this branch (not on main)
git log $MAIN_BRANCH..HEAD --oneline 2>/dev/null || echo "on-main"

# 5. Open PRs for this branch
gh pr list --head "$(git branch --show-current)" --state open --json number,title,url,statusCheckRollup 2>/dev/null || echo "no-pr"

# 6. CI status for latest commit
gh run list --branch "$(git branch --show-current)" --limit 1 --json status,conclusion,name 2>/dev/null || echo "no-runs"

# 7. Stash list
git stash list

# 8. Hostname (for prod detection)
hostname

# 9. Code review bot status
gh pr view --json reviews,comments 2>/dev/null || echo "no-pr-reviews"
```

## Step 2: Determine Stage

Based on gathered state, classify into exactly ONE stage.

### DEVIATION (check first — any match = deviation)

| Deviation | Detection | Fix |
|-----------|-----------|-----|
| **Editing on main** | Branch is `$MAIN_BRANCH` AND working tree has changes | `git stash && git checkout -b feature/NAME && git stash pop` |
| **On production machine** | Hostname matches prod host AND working tree has changes | STOP. All changes go through git from dev. |
| **Unpushed commits on main** | Branch is `$MAIN_BRANCH` AND ahead of origin | Investigate before proceeding. |
| **Detached HEAD** | `git branch --show-current` returns empty | `git checkout -b feature/NAME` or `git checkout $MAIN_BRANCH` |

### Normal Stages

| Stage | Detection | What to show |
|-------|-----------|--------------|
| **READY** | On `$MAIN_BRANCH`, clean tree, up to date | Create a feature branch |
| **DEVELOP** | On feature branch, uncommitted changes exist | Show changed files, commit |
| **COMMITTED** | On feature branch, commits exist, no upstream | Push: `git push -u origin BRANCH` |
| **PUSHED** | On feature branch, pushed, no CI run or CI running | Show CI status, wait |
| **CI_PASSED** | On feature branch, pushed, CI green, no open PR | Run pre-PR review gate (Step 7a), then create PR |
| **CI_FAILED** | On feature branch, pushed, CI red | Show failure, fix |
| **PR_WAITING** | Open PR exists, CodeRabbit check still "pending" or "in_progress" | Wait for review bot to finish |
| **PR_REVIEW** | Open PR exists, review bot posted actionable comments | **MANDATORY**: Fix all findings (Step 7b) |
| **PR_CLEAN** | Open PR exists, CI passing, all review comments addressed | Ready to merge |
| **PR_BLOCKED** | Open PR exists, CI failing or human reviewer requested changes | Fix blockers |
| **MERGED** | On `$MAIN_BRANCH`, up to date, deploy running/passed | Show deploy status |

### PR_REVIEW Detection (concrete commands)

```bash
PR_NUM=$(gh pr view --json number --jq '.number' 2>/dev/null)
GH_REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')

# Check if CodeRabbit has finished reviewing
gh pr checks $PR_NUM 2>&1 | grep -i "coderabbit"
# If "pending" → PR_WAITING. If "pass" → check for comments below.

# Count actionable inline comments from bots
gh api "repos/$GH_REPO/pulls/$PR_NUM/comments" --paginate \
  --jq '[.[] | select(.user.login | test("bot$|\\[bot\\]$"))] | length'

# Parse severity breakdown
gh api "repos/$GH_REPO/pulls/$PR_NUM/comments" --paginate \
  --jq '[.[] | select(.user.login | test("bot$|\\[bot\\]$")) | .body] |
    {"critical": [.[] | select(test("🔴 Critical"))] | length,
     "major": [.[] | select(test("🟠 Major"))] | length,
     "minor": [.[] | select(test("🟡 Minor"))] | length,
     "trivial": [.[] | select(test("🔵 Trivial|Nitpick"))] | length}'

# Also check review-level comments (outside diff range)
gh api "repos/$GH_REPO/pulls/$PR_NUM/reviews" --paginate \
  --jq '.[] | select(.user.login | test("bot$|\\[bot\\]$")) | .body' | \
  grep -E '🔴|🟠|🟡|🔵|Critical|Major|Minor|Trivial'
```

**If any Critical or Major findings exist → PR_REVIEW (blocking, must fix).**
If only Minor/Trivial and they've been reviewed → PR_CLEAN.

## Step 3: Output Format

```
## DevFlow: [STAGE_NAME]

**Branch:** `feature/xyz` (or `$MAIN_BRANCH`)
**Working tree:** clean / 3 files modified
**Remote:** up to date / 2 ahead / no upstream
**CI:** passing / failing / not run
**PR:** none / #42 open / #42 merged
**Review:** clean / 3 critical, 2 major findings / waiting for bot

### Current Status
[One sentence describing where they are]

### Next Step
[Exact command(s) to run, copy-pasteable]

### Pipeline Progress
[x] Branch from $MAIN_BRANCH
[x] Develop & commit
[ ] Push to remote        <-- YOU ARE HERE
[ ] CI passes
[ ] Pre-PR review (BugBot + CodeRabbit CLI)
[ ] Create PR
[ ] Post-PR CI passes
[ ] CodeRabbit review addressed
[ ] All comments resolved
[ ] Merge to $MAIN_BRANCH
[ ] Deploy
```

## Step 4: Guardrails (enforce ALWAYS)

1. **NEVER run auto-fixers directly on production.** All formatting goes through CI.
2. **NEVER commit directly to the main branch.** Always use feature branches.
3. **NEVER `git push --force` to the main branch.**
4. **NEVER edit files on a production machine.**
5. **NEVER restart services on production** outside of the deploy pipeline (unless explicit emergency).
6. **Feature branches should use descriptive prefixes:** `feature/`, `feat/`, `dev/`, `fix/`, or `hotfix/`.
7. **CI must pass before merge.** No skipping.
8. **ALL review bot comments must be addressed before merge.** This includes inline comments, outside-diff-range findings embedded in review bodies, and PR-level conversation comments. PR creation is NOT the finish line. Review is a mandatory stage. Do NOT declare a PR "ready to merge" while unresolved comments exist. Run the Phase 4.5 verification check before declaring clean.

## Branch Naming Convention

| Prefix | Use |
|--------|-----|
| `feature/` or `feat/` | New features |
| `fix/` | Bug fixes |
| `hotfix/` | Emergency production fixes |
| `dev/` | Experimental work |

## Step 5: "Go All The Way" Mode

When the user says "go all the way", "push through to PR", or similar:

1. **Commit** — stage changed files, draft commit message, create commit
2. **Push** — `git push -u origin BRANCH`
3. **Wait for CI** — poll `gh run list` until complete. If CI fails, fix (see Step 6)
4. **Pre-PR review gate (BLOCKING — DO NOT SKIP)** — Run Step 7a in full. This means:
   a. Run `coderabbit review --plain` — fix all Critical/Major findings
   b. Run project linter + formatter + tests one final time
   c. **You MUST NOT proceed to step 5 until 4a-4b are complete.** No exceptions. No "I'll do it later." If you skip this step, you are violating the workflow.
5. **Create PR** — `gh pr create --base $MAIN_BRANCH`
6. **Wait for post-PR CI** — `gh pr checks $PR_NUM --watch`
7. **Wait for CodeRabbit GitHub agent** — poll until "Review completed" (see Step 7b)
8. **Address ALL review findings** — mandatory loop:
   a. Parse all findings by severity
   b. Fix all Critical and Major findings
   c. Reply to each PR comment explaining the fix or why it's not applicable
   d. Commit and push
   e. Wait for new CI run to pass
   f. Wait for CodeRabbit to re-review (it re-reviews automatically on new commits)
   g. Parse new/updated comments from the re-review
   h. **Repeat from (b) until zero Critical/Major findings remain**
   i. Report Minor/Trivial to user for judgment
9. **Stop before merge** unless user explicitly said to merge too

**CRITICAL: Steps 4 and 7-8 are NOT optional.** Step 4 (pre-PR review gate) MUST run before PR creation — never skip it, even if CI passed. "Go all the way" means through review, not just to PR creation. Do NOT declare the PR ready to merge while ANY review comments are unresolved.

If the user also says "merge", proceed:
9. **Merge** — `gh pr merge --squash --delete-branch`
10. **Monitor deploy** — poll `gh run list` on `$MAIN_BRANCH` until deploy completes
11. **Report** — show deploy status

## Step 6: CI Failure Recovery

When CI fails after push:

1. Read failure logs: `gh run view <ID> --log-failed`
2. Common failures:
   - **Formatting**: Run the project's formatter, commit, push
   - **Lint**: Run linter with auto-fix, review, commit, push
   - **Tests**: Read output, fix code, commit, push
3. After fixing, wait for new CI run to pass
4. **NEVER use `--no-verify`** to bypass failing hooks. Fix the root cause.

## Step 7: Code Review — Two Phases

### 7a. Pre-PR Review Gate (LOCAL — before PR creation)

Catch as many issues as possible BEFORE creating the PR. This is cheaper and faster than fixing after review bot comments on GitHub.

1. **Run BugBot**: `/BugBot` — adversarial code review that loops until clean. Fix all CRITICAL/HIGH findings.
2. **Run CodeRabbit CLI** (if available): `coderabbit review --plain` — performs local analysis of the diff. Fix any Critical/Major findings it reports.
3. **Run project linter + formatter + tests** one final time to confirm clean state.
4. Only after all three pass clean → proceed to PR creation.

### 7b. Post-PR Review Loop (GITHUB — after PR creation)

After PR creation, the CodeRabbit GitHub review agent runs automatically. This is a **mandatory blocking loop** — do NOT skip it.

#### Phase 1: Wait for review bot

```bash
PR_NUM=$(gh pr view --json number --jq '.number')
# Poll until CodeRabbit check shows "Review completed"
gh pr checks $PR_NUM 2>&1 | grep -i "coderabbit"
# Repeat every 30 seconds until status is "pass" / "Review completed"
```

#### Phase 2: Parse ALL findings (inline + outside-diff + review body)

CodeRabbit posts findings in THREE locations. You MUST check all three:

**Source 1: Inline PR comments** (reply-able, have comment IDs)
```bash
GH_REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')

gh api "repos/$GH_REPO/pulls/$PR_NUM/comments" --paginate \
  --jq '.[] | select(.user.login | test("bot$|\\[bot\\]$")) |
    {id: .id, file: .path, line: (.original_line // .line),
     severity: (if (.body | test("🔴 Critical")) then "CRITICAL"
                elif (.body | test("🟠 Major")) then "MAJOR"
                elif (.body | test("🟡 Minor")) then "MINOR"
                elif (.body | test("🔵 Trivial|Nitpick")) then "TRIVIAL"
                else "UNKNOWN" end),
     title: (.body | split("\n") | map(select(startswith("**"))) | first // "no title")}'
```

**Source 2: Outside-diff-range findings** (embedded in review bodies, NOT individual comments)

These are findings CodeRabbit cannot post inline because they're outside the PR diff. They appear in the review body under "Outside diff range comments" with file names and line numbers. **These are easy to miss** — read the FULL body of every review:

```bash
# Get review bodies with outside-diff findings
gh api "repos/$GH_REPO/pulls/$PR_NUM/reviews" --paginate \
  --jq '.[] | select(.user.login | test("bot$|\\[bot\\]$")) |
    select(.body | test("Outside diff range")) |
    {review_id: .id, submitted_at: .submitted_at, body: .body}'
```

Parse each review body for file/line/severity/title. Outside-diff findings follow this markdown pattern:
- `> \`LINE-LINE\`: _severity_ | **Title**` followed by description

**These CANNOT be replied to as inline comments.** Address them via a PR issue comment referencing the review ID and finding.

**Source 3: PR issue comments** (top-level PR conversation)
```bash
# Check for bot comments in PR conversation
gh api "repos/$GH_REPO/issues/$PR_NUM/comments" \
  --jq '.[] | select(.user.login | test("bot$|\\[bot\\]$")) |
    {id: .id, body: (.body[:200)}'
```

#### Phase 3: Fix and respond

| Severity | Action | Blocking? |
|----------|--------|-----------|
| **Critical (🔴)** | Must fix. Bugs, security, data loss. | YES |
| **Major (🟠)** | Should fix. Quality, consistency, reliability. | YES |
| **Minor (🟡)** | Fix if valid, skip with explanation if not. | NO |
| **Trivial (🔵)** | Nice-to-have. Report to user. | NO |

For each finding:
1. Read the full comment body to understand the issue
2. Verify against actual code (bots can be wrong)
3. If valid: fix the code
4. If not applicable: prepare a reply explaining why
5. After all fixes: commit with descriptive message, push

#### Phase 4: Reply to PR comments

After fixing, reply to EACH review comment on the PR explaining what was done:

```bash
# Reply to a specific review comment
gh api "repos/$GH_REPO/pulls/$PR_NUM/comments/$COMMENT_ID/replies" \
  -f body="Fixed in <commit_sha>. <brief explanation of what changed>"
```

For findings you chose NOT to fix, reply with reasoning:
```bash
gh api "repos/$GH_REPO/pulls/$PR_NUM/comments/$COMMENT_ID/replies" \
  -f body="Not applicable here because <reason>."
```

#### Phase 4.5: Verify ALL comments have replies (MANDATORY)

Before declaring anything fixed, run this verification:

```bash
# Get all bot root comment IDs (no in_reply_to_id)
ALL_BOT=$(gh api "repos/$GH_REPO/pulls/$PR_NUM/comments" --paginate \
  --jq '[.[] | select(.user.login | test("bot$|\\[bot\\]$")) | select(.in_reply_to_id == null) | .id]')

# Get IDs that have replies
REPLIED=$(gh api "repos/$GH_REPO/pulls/$PR_NUM/comments" --paginate \
  --jq '[.[] | select(.in_reply_to_id > 0) | .in_reply_to_id] | unique')

# Compare — any in ALL_BOT not in REPLIED are UNREPLIED
echo "All bot comments: $ALL_BOT"
echo "Replied to: $REPLIED"
```

**Also check outside-diff findings are addressed** — since these can't be replied to inline, verify you posted a PR issue comment (via `issues/$PR_NUM/comments`) addressing each outside-diff finding by review ID and file/line.

**Do NOT proceed to Phase 5 until zero unreplied comments remain.**

#### Phase 5: Re-review loop

After pushing fixes, CodeRabbit automatically re-reviews. **You MUST wait for and check the re-review.**

1. Wait for CodeRabbit to post new review (poll `gh pr checks` for "Review completed")
2. Parse any NEW comments from the re-review
3. If new Critical/Major findings exist → fix, reply, push, repeat
4. Continue until re-review produces zero new Critical/Major comments
5. Only then is the PR eligible for merge

**The PR is NOT ready to merge until:**
- All CI checks pass
- All Critical/Major review findings are fixed
- All review comments have been replied to
- The latest CodeRabbit re-review has no new Critical/Major findings

## Quick Reference: Full Pipeline

```bash
# 1. Start
git checkout $MAIN_BRANCH && git pull
git checkout -b feature/my-feature

# 2. Develop + test
# ... edit files, run linter, formatter, tests ...

# 3. Push
git add <files>
git commit -m "Description"
git push -u origin feature/my-feature

# 4. Pre-PR review gate
# /BugBot — adversarial review, fix all CRITICAL/HIGH
# coderabbit review --plain — local analysis, fix Critical/Major
# Run linter + tests one more time

# 5. Create PR
gh pr create --base $MAIN_BRANCH --title "..." --body "..."

# 6. Wait for post-PR CI
gh pr checks $PR_NUM --watch

# 7. Wait for CodeRabbit GitHub agent
gh pr checks $PR_NUM 2>&1 | grep -i coderabbit
# Repeat until "Review completed"

# 8. Parse findings
PR_NUM=$(gh pr view --json number --jq '.number')
GH_REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
gh api "repos/$GH_REPO/pulls/$PR_NUM/comments" --paginate \
  --jq '.[] | select(.user.login | test("bot$|\\[bot\\]$")) |
    {file: .path, line: (.original_line // .line),
     severity: (if (.body | test("🔴 Critical")) then "CRITICAL"
                elif (.body | test("🟠 Major")) then "MAJOR"
                elif (.body | test("🟡 Minor")) then "MINOR"
                elif (.body | test("🔵 Trivial|Nitpick")) then "TRIVIAL"
                else "UNKNOWN" end),
     title: (.body | split("\n") | map(select(startswith("**"))) | first // "")}'

# 9. Fix → commit → push → wait for re-review → repeat until clean

# 10. Reply to each comment
gh api "repos/$GH_REPO/pulls/$PR_NUM/comments/$COMMENT_ID/replies" \
  -f body="Fixed in <sha>."

# 11. Merge (only when ALL comments resolved + CI green + latest re-review clean)
gh pr merge --squash --delete-branch

# 12. Monitor deploy
gh run list --limit 1

# 13. Cleanup
git checkout $MAIN_BRANCH && git pull
git branch -d feature/my-feature
```
