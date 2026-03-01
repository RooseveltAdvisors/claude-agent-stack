# CrossRepoCoordination Workflow

When a feature spans multiple repos in a workspace, coordinate DevFlow across all of them.

## When to Trigger

Activate this workflow when ANY of these are true:
- User explicitly mentions multiple repos
- Multiple repos in the workspace have uncommitted changes related to the current feature
- The feature inherently requires changes in multiple places

## Step 1: Discover Workspace Repos

**Do NOT hardcode repo paths.** Discover dynamically by scanning the workspace parent directory:

```bash
# Determine workspace root (parent of current repo)
REPO_ROOT=$(git rev-parse --show-toplevel)
WORKSPACE=$(dirname "$REPO_ROOT")

# Find all git repos in the workspace
for dir in "$WORKSPACE"/*/; do
  if [ -d "$dir/.git" ]; then
    REPO_NAME=$(basename "$dir")
    MAIN_BRANCH=$(cd "$dir" && git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    [ -z "$MAIN_BRANCH" ] && MAIN_BRANCH=$(cd "$dir" && git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}')
    CHANGES=$(cd "$dir" && git status --short | wc -l)
    echo "$REPO_NAME | branch: $(cd "$dir" && git branch --show-current) | main: $MAIN_BRANCH | changes: $CHANGES"
  fi
done
```

## Step 2: Detect Main Branch Per Repo

Each repo may use a different main branch name. **Always detect, never assume:**

```bash
cd <repo-path>
# Preferred: read from origin/HEAD
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
# Fallback: query remote
git remote show origin | grep 'HEAD branch' | awk '{print $NF}'
```

## Step 3: Process Each Repo with Changes

For each repo that has uncommitted changes:

### 3a. Fix Deviations First
If changes are on the main branch (common when editing across repos), fix immediately:
```bash
cd <repo-path>
MAIN=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
git stash
git checkout -b feature/<descriptive-name>
git stash pop
```

### 3b. Commit and Push
```bash
git add <files>
git commit -m "Description"
git push -u origin feature/<branch-name>
```

### 3c. Create PR
Detect the base branch dynamically:
```bash
MAIN=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
gh pr create --base "$MAIN" --title "..." --body "..."
```

## Step 4: Cross-Reference All PRs

After all PRs are created, update each PR body to reference the others. Discover the GitHub remote name from each repo:

```bash
cd <repo-path>
REMOTE_URL=$(git remote get-url origin)
# Extract org/repo from SSH or HTTPS URL
GH_REPO=$(echo "$REMOTE_URL" | sed -E 's#.*(github|gitlab)\.com[:/](.*)\.git$#\2#; s#.*(github|gitlab)\.com[:/](.*)$#\2#')
echo "$GH_REPO"
```

Then add to each PR:
```
## Related PRs
- org/repo-a#N (description)
- org/repo-b#N (description)
```

Use `gh pr edit <N> --body "..."` in each repo.

## Step 5: Coordinate Merging

When merging cross-repo PRs:

1. **Order matters when there are runtime dependencies.** If one repo's changes depend on another's API changes, merge the dependency first.
2. **If no dependencies, merge in parallel** — deploy workflows run independently.
3. After merge, monitor deploy workflows in each repo: `gh run list --limit 1`
4. Report final status for all repos.

## Step 6: Post-Merge Verification

Verify all deployed services (adapt to the project's infrastructure):

```bash
# Check deploy workflow status for each repo
for dir in "$WORKSPACE"/*/; do
  if [ -d "$dir/.git" ]; then
    cd "$dir"
    MAIN=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    echo "$(basename "$dir"): $(gh run list --branch "$MAIN" --limit 1 --json status,conclusion --jq '.[0] | "\(.status) \(.conclusion)"' 2>/dev/null || echo 'no workflows')"
  fi
done
```

## Branch Naming Convention

When the same feature touches multiple repos, branch names should be descriptive of what *that repo's* changes do. They don't need to be identical across repos.
