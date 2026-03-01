---
name: DevFlow
description: CI/CD workflow enforcer that detects current dev stage and guides to the next step. USE WHEN user says "devflow", "what stage", "next step", "where am I", "check flow", "push to prod", "deploy", OR at any point during development to stay on track. Prevents deviations like working on main or editing prod directly.
---

# DevFlow

CI/CD workflow guardrail for any git project. Detects where you are in the development pipeline, blocks dangerous deviations, and moves you to the next stage.

**The pipeline:** Branch → Develop → Push → PR → Review → Merge → Deploy

**The rule:** All code flows through git. Never touch production directly.

## Execution

When `/DevFlow` is invoked, read and follow `Workflows/CheckAndAdvance.md` exactly.

## Workflow Routing

| Workflow | Trigger | File |
|----------|---------|------|
| **CheckAndAdvance** | "devflow", "next step", "where am I", "check flow", any dev stage question | `Workflows/CheckAndAdvance.md` |
| **CrossRepoCoordination** | Changes span multiple repos in a workspace | `Workflows/CrossRepoCoordination.md` |

## Examples

**Example 1: Starting new work**
```
User: /DevFlow
→ Detects: on main, clean working tree
→ Output: "Stage: READY. Create a feature branch to start: git checkout -b feature/your-feature"
```

**Example 2: Mid-development**
```
User: /DevFlow
→ Detects: on feature/xyz, uncommitted changes, no remote branch
→ Output: "Stage: DEVELOP. You have uncommitted changes. Next: commit and push to trigger CI."
```

**Example 3: Ready to merge**
```
User: /DevFlow
→ Detects: on feature/xyz, pushed, CI passing, no PR
→ Output: "Stage: PR. Create a pull request: gh pr create --base main"
```

**Example 4: Deviation detected**
```
User: /DevFlow
→ Detects: uncommitted changes on main
→ Output: "DEVIATION: You have uncommitted changes on main. Stash and branch: git stash && git checkout -b feature/fix && git stash pop"
```

**Example 5: Go all the way**
```
User: "go all the way to create PR" or "push through to merge"
→ Executes ALL remaining pipeline stages automatically (commit → push → CI → PR → review findings → fix)
→ Includes mandatory review bot loop: parse CodeRabbit findings, fix Critical/Major, re-push, re-check
→ Only stops at merge unless explicitly told to merge too
```

**Example 6: PR has review findings**
```
User: /DevFlow
→ Detects: PR #17 open, CodeRabbit posted 3 Critical + 2 Major findings
→ Output: "Stage: PR_REVIEW. 3 Critical, 2 Major findings from CodeRabbit. Must fix before merge."
→ Shows each finding with file:line, severity, and title
```
