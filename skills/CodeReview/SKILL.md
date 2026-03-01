---
name: CodeReview
description: Code review and anti-pattern detection. USE WHEN user says review code, audit code, check for anti-patterns, code quality check, OR find bugs. Scans for security issues, anti-patterns, and project-specific violations.
---

# CodeReview - Code Audit and Anti-Pattern Detection

**Routes when user asks for code review, anti-pattern checks, or quality audits.**

## Overview

The CodeReview skill provides systematic code review with project-aware checks:
- Anti-pattern detection (silent exceptions, alert() usage, raw datetime calls)
- Security audits (unsanitized IDs, missing file locks)
- SQLite transaction safety verification
- Project convention enforcement

## Workflow Routing

| Workflow | Trigger | File |
|----------|---------|------|
| **ReviewCode** | "review code", "audit code", "check for anti-patterns" | `Workflows/ReviewCode.md` |

## Examples

**Example 1: Review a file for anti-patterns**
```
User: "Review app/utils/kpi_store.py for issues"
-> Invokes ReviewCode workflow
-> Scans for all known anti-patterns
-> Reports findings with severity and fix recommendations
```

**Example 2: Audit SQLite transaction safety**
```
User: "Check if our DB writes are transaction-safe"
-> Invokes ReviewCode workflow (SQLite Transaction Safety agent)
-> Scans app/utils/*.py and app/blueprints/*.py
-> Flags bare .commit() calls without transaction() context
-> Recommends db.transaction() or self._transaction() wrappers
```

**Example 3: Full code quality check**
```
User: "Run a full code quality audit"
-> Invokes ReviewCode workflow with all agents
-> Checks exceptions, security, timestamps, phone numbers, SQLite safety
-> Produces consolidated report
```
