# AdversarialReview Workflow

> **Trigger:** "bugbot", "deep review", "adversarial review", "review until clean", "find all bugs"

## Purpose

Iteratively attack code changes from every angle until a full review pass finds zero new bugs. Each iteration uses a different set of attack angles. When a bug is found: score its severity and confidence, fix it, write a regression test, then continue to the next angle. Only declare clean when all ODC trigger categories are covered, an entire pass finds nothing, **and a runtime smoke test confirms the app actually works** (builds, loads, renders core UI, no console errors).

## Design Influences

| Source | Technique Borrowed |
|--------|-------------------|
| **Cursor BugBot** | Parallel passes with shuffled file ordering + majority voting for consensus |
| **Meta ACH** | Fault-aware test generation — every fix gets a test that would have caught it |
| **Trail of Bits** | Evidence-based findings with exact file:line citations, no hallucinated bugs |
| **IBM ODC** | Trigger coverage tracking — review completeness measured by trigger categories covered |
| **HP Defect Origins** | Missing/Wrong/Unclear lens applied to every code element |
| **CERT** | Severity x Likelihood x Remediation Cost prioritization (cheap fixes get higher priority) |
| **SmartBear/Cisco** | <400 LOC per agent focus, <60 min per pass (empirical performance ceiling) |
| **MAGIS (NeurIPS)** | Developer ↔ QA feedback loop — QA rejection feeds back as context for next attempt |
| **Ellipsis** | Multi-stage filtering: confidence threshold → dedup → hallucination check |

## Runs Inside a Ralph Wiggum Loop

This workflow is launched automatically by `/BugBot` via a Ralph Wiggum loop. The loop feeds the SAME prompt each iteration until `<promise>ALL_CLEAN</promise>` is output.

### Critical: Fresh Context Each Iteration

Each ralph-loop iteration starts with a **completely fresh conversation context**. You do NOT remember previous iterations. Your memory across iterations is:

1. **The state file** (path provided in the prompt as `STATE FILE: ...`) — This is your primary memory. Read it FIRST every iteration.
2. **Files on disk** — Your fixes, tests, and code changes persist.
3. **Git history** — Your commits from previous iterations are visible via `git log`.

**First action every iteration:** Read the state file path given in the prompt. If it doesn't exist, this is iteration 1 — create it. If it exists, continue from where the previous iteration left off.

## Project Toolchain Detection

If the prompt includes `OVERRIDES: none`, auto-detect the project's toolchain:

### Lint/Format Detection
Check for these files in the project root (in order of priority):
- `pyproject.toml` → use `ruff check` and `ruff format --check` (or `black --check` if ruff not configured)
- `package.json` → check for `eslint` in devDependencies → `npx eslint`
- `Cargo.toml` → `cargo clippy` and `cargo fmt --check`
- `go.mod` → `golangci-lint run` (if installed) or `go vet`
- Fall back to no lint if nothing detected

### Test Detection
- `pyproject.toml` or `pytest.ini` or `tests/` dir → `pytest` (with project's runner, e.g. `uv run -m pytest`)
- `package.json` with `test` script → `npm test` or `bun test`
- `Cargo.toml` → `cargo test`
- `go.mod` → `go test ./...`
- Fall back to no test if nothing detected

Record detected commands in the state file under `## Toolchain`.

## Confidence Scoring Matrix

Every finding MUST be scored on two axes. This is non-optional.

### Severity (what's the worst case?)

| Level | Label | Description | Examples |
|-------|-------|-------------|----------|
| S3 | Critical | Data breach, auth bypass, data corruption, silent data loss | SQL injection, missing auth check, writing wrong user's data |
| S2 | Moderate | Info leak, denial of service, privilege escalation, incorrect behavior | XSS, unhandled error crashes page, wrong data displayed |
| S1 | Minor | Code quality, defense-in-depth, maintainability | Missing log, unclear variable name, redundant check |

### Confidence (how sure are you?)

| Level | Label | Description | Evidence Required |
|-------|-------|-------------|-------------------|
| C3 | Confirmed | Concrete proof — specific input triggers it, or provably missing check | Exact file:line, code snippet, trigger scenario |
| C2 | Probable | Strong evidence — matches known vulnerability pattern, but no PoC | File:line, code snippet, reasoning chain |
| C1 | Possible | Suspicious pattern — could be an issue depending on unseen context | File:line, concern description |

### Priority Matrix

| | C3 (Confirmed) | C2 (Probable) | C1 (Possible) |
|---|---|---|---|
| **S3 (Critical)** | **CRITICAL** — fix before merge | **HIGH** — fix before merge | **MEDIUM** — fix recommended |
| **S2 (Moderate)** | **HIGH** — fix before merge | **MEDIUM** — fix recommended | **LOW** — log for later |
| **S1 (Minor)** | **MEDIUM** — fix recommended | **LOW** — log for later | **INFO** — note only |

**Completion blocking:** Only CRITICAL and HIGH findings block the ALL_CLEAN promise. MEDIUM gets fixed if iteration budget allows. LOW/INFO are logged in the state file for future work.

### Consensus Upgrade Rule (from Cursor BugBot)

When 2+ agents independently flag the same issue (even from different angles), auto-upgrade confidence by one level:
- C1 → C2
- C2 → C3

This is the majority voting mechanism. Agents don't see each other's results — consensus emerges independently.

## Evidence Requirement

Inspired by Trail of Bits and Ellipsis. Every finding MUST include:

```
**BUG FOUND** [SEVERITY x CONFIDENCE = PRIORITY]
- **Location:** `src/auth/handler.py:142`
- **Code:**
  ```python
  if user.role in allowed_roles:  # BUG: doesn't check token expiry
  ```
- **Issue:** Authorization check doesn't verify token hasn't expired.
  An expired token with valid role still passes.
- **Fix:** Add token expiry check before role comparison.
- **Missing/Wrong/Unclear:** MISSING — no expiry validation in auth handler.
- **ODC Trigger:** Complex path (expired token with valid role).
```

Findings without file:line evidence are auto-downgraded to C1 (Possible).

## ODC Trigger Coverage

Adapted from IBM's Orthogonal Defect Classification. Each trigger category represents a different way bugs manifest. Review is not complete until all relevant categories have been tested.

Track coverage in the state file:

| Trigger | Description | How to Test |
|---------|-------------|-------------|
| **Simple path** | Happy path, normal inputs | Walk through the main use case |
| **Complex path** | Multi-step flows, conditional branches | Follow every if/else, loop boundary |
| **Boundary** | Edge values, limits, empty/null/max | Test 0, 1, MAX, empty string, null |
| **Error recovery** | What happens when things fail? | Network error, invalid input, DB locked |
| **Stress/volume** | High load, large data, rapid interaction | Max items, double-click, concurrent users |
| **Interaction** | Cross-feature, cross-component effects | Feature A writes data that Feature B reads |
| **Configuration** | Different settings, roles, environments | Different user roles, missing env vars |

Minimum coverage for ALL_CLEAN: all 7 trigger categories must have at least one angle that tested them.

## HP Missing/Wrong/Unclear Lens

Every agent MUST apply this lens to each significant code element it reviews. This is a simple but empirically powerful framework from HP's defect taxonomy:

- **Missing** — Is anything that should be here absent? (missing validation, missing error handling, missing audit log, missing test)
- **Wrong** — Is anything here incorrect? (wrong comparison, wrong variable, wrong return type, wrong assumption)
- **Unclear** — Is anything here ambiguous or likely to confuse future developers? (unclear naming, unclear control flow, unclear side effects)

Include the applicable M/W/U classification in every finding.

## State File

Path: provided in the ralph-loop prompt as `STATE FILE: .claude/review-state-{ID}.md`. Each BugBot session gets a unique state file so parallel sessions don't conflict.

Created on first iteration, updated each iteration:

```markdown
# BugBot Review State

## Toolchain
- Lint: `ruff check` (auto-detected from pyproject.toml)
- Format: `ruff format --check`
- Test: `uv run -m pytest`

## Target
[feature description and file list]

## Trigger Coverage
- [x] Simple path (Iteration 1: angles 1, 5)
- [x] Complex path (Iteration 1: angle 6)
- [x] Boundary (Iteration 2: angle 22)
- [ ] Error recovery
- [x] Stress/volume (Iteration 2: angle 23)
- [x] Interaction (Iteration 1: angles 1, 2, 3)
- [ ] Configuration

## Iteration Log

### Iteration 1
**Angles tried:** 1 (adjacent feature mutation), 5 (round-trip consistency), 6 (NULL/empty/missing)
**Mechanical pre-pass:** ruff clean, 0 issues
**Findings:** 2 bugs found
- [x] **[S2 x C3 = HIGH]** BUG: json.loads could return non-list in format_user_for_display
  - Location: `src/utils/user_db.py:653`
  - M/W/U: WRONG — assumes json.loads always returns list
  - Fixed: added isinstance check
  - Test: test_user_display.py::test_non_list_json
- [x] **[S2 x C3 = HIGH]** BUG: email not lowercased before comparison
  - Location: `src/handlers/user.py:142`
  - M/W/U: WRONG — comparing raw vs normalized format
  - Fixed: used .lower() before comparison
  - Test: test_user_handler.py::test_case_insensitive_email

### Iteration 2
**Angles tried:** 3 (stale state), 9 (response shape), 12 (optimistic UI)
**Findings:** 0 bugs found

## Angles Completed
- [x] 1. Adjacent feature mutation
- [x] 5. Round-trip consistency
- [x] 6. NULL vs empty vs missing
- [x] 3. State sync after mutations
- [ ] 24. Concurrent editing
...

## Runtime Smoke Test
- Build: PASS
- App loads: PASS (http://localhost:5173)
- Console errors: NONE
- Core UI renders: PASS (11 panels rendered with content)
- Primary features visible: PASS (news items, filter tabs, map layers)

## Consensus Tracker
(Issues flagged by 2+ agents independently — auto-upgraded confidence)
- None yet
```

## Attack Angle Catalog

Each iteration should pick 3-5 UNTRIED angles from this catalog. Agents run in parallel. Each agent receives files in a **shuffled order** (different from other agents) to encourage diverse reasoning paths.

### Category A: Cross-Feature Interactions
*ODC Triggers covered: Interaction, Complex path*

1. **Adjacent feature mutation** — If feature X writes field F, what other features read F? Do they handle the new values?
2. **Shared endpoint callers** — If an endpoint was modified, who else calls it? Do they send data that hits new validation?
3. **State sync after mutations** — After a write succeeds, do all in-memory/cache/UI references get updated? Or do they go stale?
4. **Event cascade** — Does the change trigger event broadcasts, audit logs, cache invalidation? Are all side effects present?

### Category B: Data Integrity
*ODC Triggers covered: Boundary, Complex path*

5. **Round-trip consistency** — Trace data from write → serialize → store → deserialize → display. Any lossy step?
6. **NULL vs empty vs missing** — What happens at each layer when the value is NULL, empty string, empty list, or missing key?
7. **Type coercion boundaries** — JSON string vs native type vs DB column type. Does each boundary handle all types?
8. **Merge/migration paths** — Do bulk operations (merge records, migrate data) handle the new field correctly?

### Category C: Client-Server Contract
*ODC Triggers covered: Simple path, Complex path, Error recovery*

9. **Response shape consistency** — Does the client handle all possible response shapes (missing keys, null, error responses)?
10. **Validation mismatch** — Does client-side validation match server-side? Can the client send something the server rejects (or vice versa)?
11. **Error path UX** — What does the user see on network error, 502, invalid response, null data?
12. **Optimistic vs pessimistic UI** — Does the UI update before or after server confirmation? Race on double-click?

### Category D: Security & Safety
*ODC Triggers covered: Complex path, Configuration*

13. **Input sanitization** — XSS in template expressions, innerHTML with user data, command injection, SQL injection?
14. **Authorization** — Can a lower-privilege role access the new functionality? Are permission checks correct?
15. **Audit trail** — Are all write operations logged? Are side-effect writes (cleanup, cascade) also logged?
16. **CSRF/SSRF** — Does the endpoint require CSRF protection? Are server-side requests validated?

### Category E: Template & Display
*ODC Triggers covered: Simple path, Configuration*

17. **All render callers** — Does every caller of the template/component pass the required new variables/props?
18. **i18n coverage** — If the UI uses i18n keys, do they exist for all supported languages?
19. **CSS/style conflicts** — Do new class names or styles collide with existing ones?
20. **Accessibility** — Keyboard navigation, aria-labels, focus management after DOM changes?

### Category F: Edge Cases & Stress
*ODC Triggers covered: Boundary, Stress/volume*

21. **Empty state** — What happens when there are zero items? Does the UI show a placeholder?
22. **Max capacity** — What happens at the limit? Does the UI handle overflow gracefully?
23. **Rapid interaction** — Double-click, rapid add/remove, type-ahead race conditions
24. **Concurrent editing** — Two sessions, two users, API vs UI simultaneously

### Category G: Ecosystem Impact
*ODC Triggers covered: Interaction, Configuration*

25. **Search/index** — Does the search system include the new field? Should it?
26. **Export/serialization** — Do data exports include the new data in the correct format?
27. **API consumers** — Do any external integrations receive this data? Do they handle the new shape?
28. **Multi-environment** — Does this work in dev, staging, production? Different configs, different databases?

## Workflow Steps Per Iteration

### Phase 0: Mechanical Pre-Pass (Automated)

Before any LLM agent runs, execute mechanical checks to catch trivial issues and reduce noise:

Use the lint/format/typecheck commands from the state file's `## Toolchain` section (or auto-detect if first iteration). Example:

```bash
# Python project
ruff check {target_files}
ruff format --check {target_files}

# Node.js project
npx eslint {target_files}
npx prettier --check {target_files}

# Rust project
cargo clippy -- -D warnings
cargo fmt --check

# Go project
golangci-lint run {target_files}
gofmt -l {target_files}
```

Log results in the state file. Fix any issues before proceeding to agent review.

#### Dead Call Detection

Grep for every method called via `as any` or dynamic dispatch in the changed files. For each, verify the target class actually implements that method. Example:

```bash
# Find all (x as any)?.someMethod() calls and check if someMethod exists
grep -rn "as any)" {target_files} | grep -oP ".\w+\(" | sort -u
# For each method found, verify it exists on the actual target class
```

A method called but never defined is an automatic **CRITICAL** finding — it means a feature silently does nothing.

#### Data Pipeline Completeness

For every data fetch in the changed files, trace the full pipeline:

1. **Fetch** — Is the API actually called? (check for missing invocation on startup/init)
2. **Store** — Does the result get stored in a field on the correct object?
3. **Expose** — If there is a wrapper/proxy/container class, does it delegate the setter method?
4. **Render** — Is the stored data read and rendered somewhere? (check buildLayers, render methods, templates)

Any broken link in the chain (fetched but not stored, stored but not rendered, method exists on inner class but not exposed by wrapper) is an automatic **HIGH** finding.

### Step 1: Read State

```
Read the state file (or create it if first iteration).
Identify which angles from the catalog have NOT been tried yet.
Check ODC trigger coverage — prioritize angles that cover uncovered triggers.
Pick 3-5 untried angles for this iteration.
```

### Step 2: Identify Target Files

```
If "use git diff": run `git diff --name-only HEAD~N` to find changed files.
Otherwise use the file list from the prompt.
Read all target files to understand the changes.
```

### Step 3: Spawn Review Agents

Launch 3-5 parallel agents (one per attack angle). Each agent's prompt MUST:
1. State the specific attack angle
2. List the target files to examine — **in a different shuffled order per agent**
3. Require the agent to READ the actual code (not guess)
4. Require the **Missing/Wrong/Unclear** lens on each code element
5. Require **evidence** (file:line + code snippet) for every finding
6. Require **Severity x Confidence scoring** for every finding
7. Ask for a verdict: BUG FOUND (with full evidence block) or CLEAN

```
Example agent prompt:
"ATTACK ANGLE: Stale client-side state after server mutation
TARGET FILES (review in this order):
  1. src/handlers/user.py
  2. src/components/UserProfile.tsx
FEATURE: User profile editing

After a successful write to the server, check whether all client-side
variables and DOM elements are updated to reflect the new state. Look for:
- Variables initialized once but never refreshed after mutation
- UI updated optimistically but never reconciled with server response
- Stale closures or references after async operations

For EACH significant code element, apply the Missing/Wrong/Unclear lens:
- MISSING: Is any state update absent after a successful write?
- WRONG: Is any variable updated with the wrong value or at the wrong time?
- UNCLEAR: Is any state management flow confusing or brittle?

READ the actual code. For any finding, you MUST provide:
1. Severity (S1/S2/S3) and Confidence (C1/C2/C3) with justification
2. Exact file:line location
3. Code snippet showing the problem
4. Which M/W/U category it falls under
5. Which ODC trigger category this exercises

Report BUG FOUND with full evidence block (see Evidence Requirement), or CLEAN."
```

### Step 4: Process Results

**For each BUG FOUND:**
1. **Check consensus** — If 2+ agents flagged the same issue, auto-upgrade confidence
2. **Prioritize** — CRITICAL and HIGH first, then MEDIUM if budget allows
3. **Fix the bug** — Edit the source file
4. **Write a regression test** — Add a test that would have caught this bug
5. **Run the test** — Verify it passes
6. **Log it** — Update the state file with the full evidence block

**For CLEAN results:**
- Mark the angle as completed in the state file
- Update ODC trigger coverage

**For LOW/INFO findings:**
- Log in state file under a "Deferred" section
- Do NOT fix during this iteration (avoid scope creep)

### Step 5: Runtime Smoke Test (MANDATORY before ALL_CLEAN)

Static analysis alone is insufficient. This step catches crashes, blank screens, and runtime errors that only manifest when the app actually runs. **This step is NON-OPTIONAL.**

**For web/frontend projects:**

1. **Build the project** — Run the project's build command (e.g., `npm run build`, `vite build`). If there's a variant, build the target variant.
2. **Start the app** — Launch a dev or preview server in the background.
3. **Load in browser** — Use `agent-browser` (or the project's browser automation) to navigate to the app.
4. **Check for crash signals:**
   - Console errors (`TypeError`, `ReferenceError`, unhandled promise rejections)
   - Blank/empty render (zero children in main content container)
   - HTTP errors (4xx/5xx on critical resources)
   - White screen of death
5. **Verify core functionality renders** — At minimum, confirm the main UI elements (panels, navigation, content areas) are present and populated. Don't just check that the page loads — verify that the PRIMARY FEATURES of the changed code are visually present.
6. **Verify data presence (not just no-crash)** — An empty map, blank panel, or loading spinner is NOT a pass. For each major data-driven component changed:
   - Check that data containers have actual child elements (not zero items)
   - For maps: verify layers exist and have data points (e.g., DeckGL layer count > 0)
   - For lists/panels: verify item count > 0, not just that the container exists
   - For API-driven features: verify network requests returned 200 and data reached the UI
   - A feature that renders its chrome but shows no data is a **CRITICAL** finding — it means the data pipeline is broken.
6. **Stop the server** when done.

**For backend/API projects:**

1. Build and start the server.
2. Hit the primary endpoints with curl/httpie.
3. Verify responses are valid (correct status codes, non-empty bodies, correct content types).
4. Stop the server.

**For library/CLI projects:**

1. Build the project.
2. Run the primary entry point with sample input.
3. Verify output is correct.

**If the smoke test fails** — the failure is an automatic CRITICAL finding. Fix it, log it in the state file, and do NOT output the promise. The smoke test failure takes priority over all other work.

**Log the smoke test** in the state file under `## Runtime Smoke Test`:
```markdown
## Runtime Smoke Test
- Build: PASS/FAIL
- App loads: PASS/FAIL
- Console errors: NONE / [list errors]
- Core UI renders: PASS/FAIL (list what was checked)
- Primary features visible: PASS/FAIL
- Data presence: PASS/FAIL (list data-driven components checked and their item counts)
```

### Step 6: Decide Continue or Complete

```
IF any CRITICAL or HIGH bugs were found this iteration:
  → Update state file, do NOT output promise
  → (Ralph loop will re-invoke with next iteration)

IF zero CRITICAL/HIGH bugs found AND all 7 ODC triggers covered AND at least 15 angles completed:
  → Run all tests one final time
  → Run the Runtime Smoke Test (Step 5) — this is MANDATORY
  → IF tests pass AND smoke test passes: output <promise>ALL_CLEAN</promise>
  → IF tests fail OR smoke test fails: fix and do NOT output promise

IF zero bugs found BUT ODC trigger coverage incomplete:
  → Pick angles that cover missing triggers
  → Continue to next iteration
  → Do NOT output promise yet

IF zero bugs found BUT fewer than 15 angles completed:
  → Continue to next iteration with more angles
  → Do NOT output promise yet
```

## Agent Prompt Templates

### Cross-Feature Interaction Agent
```
ATTACK ANGLE: Cross-feature interaction
TARGET FILES: {files_shuffled}
FEATURE: {description}

For each endpoint or function modified in the target files:
1. Find ALL other callers of that endpoint/function (grep the codebase)
2. Check if callers send data that hits new validation/normalization
3. Check if callers read response fields that changed shape
4. Check if callers have their own copy of logic that should be unified

Apply Missing/Wrong/Unclear lens to each caller interaction.
Score each finding with Severity (S1-S3) x Confidence (C1-C3).
Cite exact file:line with code snippet for every finding.

Report BUG FOUND with full evidence block, or CLEAN.
```

### Data Round-Trip Agent
```
ATTACK ANGLE: Data round-trip consistency
TARGET FILES: {files_shuffled}

For each new or modified data field:
1. Trace: input → validation → serialization → storage → deserialization → output → display
2. At each boundary, check: What if the value is NULL? Empty string? Empty list? Wrong type?
3. Check: Does the serializer and deserializer produce consistent round-trips?
4. Check: Does the display layer handle all possible stored values?

Apply Missing/Wrong/Unclear lens at each boundary crossing.
Score each finding with Severity (S1-S3) x Confidence (C1-C3).
Cite exact file:line with code snippet for every finding.

Report BUG FOUND with the exact boundary where data is lost/corrupted, or CLEAN.
```

### Stale State Agent
```
ATTACK ANGLE: Stale state after mutation
TARGET FILES: {files_shuffled}

After a successful write operation:
1. List ALL variables/state initialized from initial data load or previous responses
2. For each: Is it updated from the new response? Or does it hold the stale initial value?
3. Check: Are there immutability constraints preventing updates? (const, frozen objects, etc.)
4. Check: After UI rebuild, are event handlers still attached? Are references duplicated?

Apply Missing/Wrong/Unclear lens to each variable's lifecycle.
Score each finding with Severity (S1-S3) x Confidence (C1-C3).
Cite exact file:line with code snippet for every finding.

Report BUG FOUND with variable name, file:line, and what goes stale, or CLEAN.
```

### Audit Trail Agent
```
ATTACK ANGLE: Audit trail completeness
TARGET FILES: {files_shuffled}

For each write operation (INSERT/UPDATE/DELETE) in the target files:
1. Is there a logging/audit call covering this write?
2. If the write is conditional, is the audit log inside the same condition?
3. If there are multiple write paths (if/else branches), does EACH path have its own audit log?
4. Does the audit log capture which fields changed?

Apply Missing/Wrong/Unclear lens — especially MISSING (unlogged writes).
Score each finding with Severity (S1-S3) x Confidence (C1-C3).
Cite exact file:line with code snippet for every finding.

Report BUG FOUND with the unlogged write and its location, or CLEAN.
```

### Authorization Agent
```
ATTACK ANGLE: Authorization and access control
TARGET FILES: {files_shuffled}

For each endpoint or UI control in the target files:
1. What roles can access this? Is the check correct?
2. Can a lower-privilege role reach this via direct URL/API call?
3. Are permission checks consistent between different access paths?
4. Does the UI hide controls that the server also enforces? (defense in depth)

Apply Missing/Wrong/Unclear lens — especially MISSING (unchecked paths).
Score each finding with Severity (S1-S3) x Confidence (C1-C3).
Cite exact file:line with code snippet for every finding.

Report BUG FOUND with the authorization gap and its location, or CLEAN.
```

### Error Recovery Agent
```
ATTACK ANGLE: Error handling and recovery paths
TARGET FILES: {files_shuffled}

For each operation that can fail (network calls, DB queries, file I/O, parsing):
1. What happens on failure? Does the user see a helpful message or a blank screen?
2. Is the error caught at the right level? (not too broad, not too narrow)
3. After an error, is the system in a consistent state? (no half-written data)
4. Are error responses properly formatted for the consumer? (JSON for API, user-friendly for UI)

Apply Missing/Wrong/Unclear lens — especially MISSING (uncaught errors).
Score each finding with Severity (S1-S3) x Confidence (C1-C3).
Cite exact file:line with code snippet for every finding.

Report BUG FOUND with the unhandled error path and its location, or CLEAN.
```

### Category H: Data Pipeline Integrity
*ODC Triggers covered: Simple path, Interaction, Configuration*

29. **Dead method calls** — Grep for every method invoked via `as any`, dynamic dispatch, or cross-module boundary. Verify each target class actually implements the method. A called-but-undefined method is silent data loss.
30. **Wrapper/proxy delegation** — If class A wraps class B (proxy, container, adapter), verify that every public method on B that callers need is also exposed by A. Missing delegation = silent no-op.
31. **API contract match** — For each external API call, verify the response field names match what the code reads. Check actual API docs or curl the endpoint. Wrong column names = empty data.
32. **Init-time data loading** — Verify that data-driven features have their loaders called on startup, not just on user interaction. If variant X enables layers/features by default, check that the init path actually loads their data.
33. **External API data freshness** — For each third-party API call, verify the data source returns CURRENT data (not stale/deprecated). Curl the endpoint with the exact query parameters used in code and check: (a) response is 200 not 404, (b) date fields in the response are recent (within expected update cadence), (c) column/field names in the code match the actual API response schema. A stale API that silently returns no data or old data is an automatic CRITICAL finding — the feature renders empty with no error.
34. **API query parameter correctness** — For each API URL constructed in code, verify every query parameter ($order, $where, $select, $limit) references columns that actually exist in the target dataset. Curl the API with the exact constructed URL. A column-name typo causes a silent error or empty response. Check dataset documentation or introspect the API schema.

### External API Validation Agent
```
ATTACK ANGLE: External API data freshness and contract validation
TARGET FILES: {files_shuffled}

For each external/third-party API call (fetch, axios, http) in the target files:
1. Extract the full URL including query parameters ($order, $where, $select, field names)
2. Curl the EXACT URL and check: Does it return 200? Does it return data? Are date fields recent?
3. Compare field names in the code (response parsing) against actual response keys — any mismatch = silent empty data
4. Check if the API/dataset is deprecated, moved, or returns stale data (e.g., last updated >6 months ago)
5. For SODA/OData APIs: verify $order, $where, $select reference real column names (not assumed ones)

Apply Missing/Wrong/Unclear lens:
- WRONG: Code references column "date" but API has "date_end" → silent empty response
- WRONG: API data is stale (last record from 2024) → feature renders with no data
- MISSING: No validation that API response contains expected data before rendering

Score each finding with Severity (S1-S3) x Confidence (C1-C3).
Cite exact file:line with the URL construction and the actual API response.

Report BUG FOUND with the API mismatch and its location, or CLEAN.
```
