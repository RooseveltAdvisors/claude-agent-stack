# ReviewCode Workflow

> **Trigger:** "review code", "audit code", "check for anti-patterns", "code quality check"

## Purpose

Systematically audit code for anti-patterns, security issues, and project convention violations. Each audit agent focuses on a specific concern and can run independently or as part of a full review.

## Audit Agents

Run the relevant agents based on the user's request. For a full review, run all agents.

---

### Agent 1: Silent Exception Handling

**Pattern to detect:** bare `except: pass` or `except Exception: pass` without logging

**Why it's bad:** Swallowed exceptions hide bugs and make debugging impossible.

**Fix:** Always log the exception, even if the code continues:
```python
# WRONG
try:
    do_thing()
except:
    pass

# RIGHT
try:
    do_thing()
except Exception as e:
    logger.error(f"Failed to do thing: {e}")
```

**Files to scan:** `app/**/*.py`

---

### Agent 2: JavaScript Alert/Confirm Usage

**Pattern to detect:** `alert()` or `confirm()` calls in JavaScript

**Why it's bad:** Native browser dialogs block the UI thread and cannot be styled. The project uses custom modal utilities.

**Fix:** Use `showToast()` for notifications and `showConfirmModal()` for confirmations.

**Files to scan:** `static/js/**/*.js`, `templates/**/*.html`

---

### Agent 3: Raw Datetime Usage

**Pattern to detect:** `datetime.now().isoformat()` or bare `date.today()`

**Why it's bad:** These use the server's local timezone, not UTC. The project requires timezone-aware timestamps.

**Fix:** Use `utc_now_iso()` for timestamps and `site_today(site_name)` for dates.

**Files to scan:** `app/**/*.py`

---

### Agent 4: Unsanitized ID Parameters

**Pattern to detect:** Filesystem operations using IDs without regex validation `^[a-zA-Z0-9_:\-]+$`

**Why it's bad:** Path traversal attacks via malicious IDs.

**Fix:** Validate IDs with regex before any filesystem operation.

**Files to scan:** `app/blueprints/*.py`, `app/utils/*.py`

---

### Agent 5: Missing File Locks

**Pattern to detect:** File writes without `file_lock()` context manager

**Why it's bad:** Concurrent writes corrupt data.

**Fix:** Wrap file writes in `with file_lock(path):` blocks.

**Files to scan:** `app/utils/*.py`

---

### Agent 6: SQLite Transaction Safety

**Pattern to detect:** Bare `.commit()` calls without `transaction()` or `BEGIN IMMEDIATE` context

**Why it's bad:** Python's sqlite3 module uses DEFERRED transactions by default. A DEFERRED transaction only acquires a SHARED lock on first read, then tries to upgrade to a RESERVED/EXCLUSIVE lock on write. Under concurrent load, this lock upgrade fails instantly with `SQLITE_LOCKED` (error code 6), which bypasses `busy_timeout` entirely. The `busy_timeout` only helps when acquiring the initial lock, not when upgrading. This causes intermittent "database is locked" errors that are extremely hard to reproduce in development but happen regularly in production.

**Fix:** All database write operations must use one of:
- `db.transaction()` context manager (which issues `BEGIN IMMEDIATE`) for code using the `Database` wrapper class
- `self._transaction()` for services with direct `sqlite3` connections (must implement `BEGIN IMMEDIATE` internally)

`BEGIN IMMEDIATE` acquires a RESERVED lock at transaction start, before any reads. This means `busy_timeout` works correctly because the lock is acquired (not upgraded) and SQLite will wait/retry rather than failing instantly.

**Files to scan:** `app/utils/*.py`, `app/blueprints/*.py`

**Exceptions:** The following files are exempt from this check:
- `app/utils/database.py` (defines the `transaction()` method itself)
- `app/utils/data_store.py` (database initialization and migration code)
- Any `init_db()`, `_migrate()`, or `_ensure_tables()` methods (one-time setup, not concurrent)

**What to flag:**
1. Any `.commit()` call that is NOT inside a `with db.transaction()` or `with self._transaction()` block
2. Any `execute("INSERT|UPDATE|DELETE ...")` followed by `.commit()` without a transaction context
3. Any `conn.commit()` where `conn` was obtained outside a `BEGIN IMMEDIATE` block

**Example findings:**
```
FINDING: app/utils/kpi_store.py:210 - bare self.db.commit() without transaction() context
SEVERITY: High
FIX: Wrap the surrounding write operations in `with self.db.transaction():` block

FINDING: app/utils/billing_service.py:213 - data_store.commit() outside transaction
SEVERITY: High
FIX: Move this write into the existing transaction() block or create a new one
```

---

## Workflow Steps

### Step 1: Determine Scope

Ask (or infer from context):
- Which files or directories to scan?
- Which agents to run? (default: all)
- Severity threshold? (default: report all)

### Step 2: Run Agents

For each active agent:
1. Search for the anti-pattern using Grep
2. Read surrounding context to confirm it is a true positive
3. Check for exemptions (e.g., database.py for Agent 6)
4. Record findings with file, line number, severity, and fix

### Step 3: Report Findings

Output format:
```
## Code Review Results

### [Agent Name]
| File | Line | Severity | Finding |
|------|------|----------|---------|
| path/to/file.py | 42 | High | Bare .commit() without transaction() |

**Recommended fix:** [specific fix for this finding]
```

### Step 4: Summary

```
## Summary
- Files scanned: N
- Findings: N (High: X, Medium: Y, Low: Z)
- Clean agents: [list of agents with no findings]
```
