# CaptureFlow Workflow

> **Trigger:** "capture flow", "document workflow", "record steps", "trace user journey"

Documents a multi-step user flow across one or more pages: each step gets a screenshot and description.

## Prerequisites

- Chrome DevTools MCP running
- Know the starting URL/page and the flow to capture
- Know the flow name for file naming

## Input Parameters

- **flow_name:** Short identifier (e.g., "signup", "checkout", "patient-checkin")
- **start_url:** Where the flow begins
- **output_dir:** Output directory (default: `.agent/web-explore/`)
- **goal:** What the user accomplishes by completing this flow

## Steps

### Step 1: Setup

Create output structure:
```
[output_dir]/flows/[flow_name]/
  screenshots/
  [flow_name]-flow.md  ← spec file
```

Initialize spec file:
```markdown
# [App] — [Flow Name] Flow

**Date:** YYYY-MM-DD
**Starting URL:** [start_url]
**Goal:** [What the user accomplishes]
**Steps:** [Will be filled in]

---
```

### Step 2: Navigate to Start

```
navigate_page type: "url", url: "[start_url]"
wait_for text: "[expected content]"
take_snapshot
```

### Step 3: For Each Step in the Flow

Repeat this pattern for every user action:

```
# Before action:
take_screenshot filePath: "[output_dir]/flows/[flow_name]/screenshots/step-[N]-before.png"
take_snapshot  ← get UIDs for the elements you'll interact with

# Document this step in spec:
## Step N: [Step Name]
**Screenshot:** `screenshots/step-N-before.png`
**State:** [Description of what the user sees]
**Action:** [What the user does — click X, fill Y, select Z]

# Perform the action:
[click / fill / select using UID from snapshot]
wait_for text: "[confirmation or next step indicator]"

# After action:
take_screenshot filePath: "[output_dir]/flows/[flow_name]/screenshots/step-[N]-after.png"
take_snapshot  ← verify new state

# Document result:
**Result:** [What changed after the action]
**Next State:** [What the user now sees]
```

### Step 4: Document Data Captured in Flow

For any forms encountered, document the data model:

```markdown
## Data Collected in Flow

| Step | Field | Type | Required | Validation |
|------|-------|------|----------|------------|
| 2 | Email | text | Yes | Valid email |
| 2 | Password | password | Yes | Min 8 chars |
| 3 | Plan | select | Yes | Free, Pro, Enterprise |
```

### Step 5: Identify Decision Points

Note any branching in the flow:

```markdown
## Decision Points

### At Step [N]: [Decision Name]
- **Option A:** [Condition] → leads to [path]
- **Option B:** [Condition] → leads to [path]
```

### Step 6: Complete the Spec

Final spec structure:

```markdown
# [App] — [Flow Name] Flow

**Date:** YYYY-MM-DD
**Starting URL:** [start_url]
**Goal:** [What the user accomplishes]
**Total Steps:** [N]
**Screenshots:** `flows/[flow_name]/screenshots/`

## Overview

[1-3 sentences describing the flow and when users encounter it]

## Step-by-Step

### Step 1: [Step Name]
**Screenshot:** `screenshots/step-1-before.png`
**State:** [What user sees]
**Action:** [What user does]
**Result:** [What happens]

### Step 2: [Step Name]
[Continue pattern...]

## Data Model

[Table of all fields collected]

## Decision Points

[Branching logic]

## Error States

| Trigger | Error Shown | Recovery |
|---------|-------------|----------|
| [What causes it] | [Error message/state] | [How user recovers] |

## Notes

- [Performance observations]
- [Unusual behaviors]
- [Accessibility notes]
```

### Step 7: Update NavigationTips.md

```markdown
## [Flow Name] Flow

**Entry Point:** [URL]
**Duration:** ~[N] steps

**Critical Notes:**
- [Gotcha 1]
- [Gotcha 2]
```

## Tips

- **Capture before AND after** each action — especially for async operations
- **Don't skip error states** — try intentional bad input to capture validation
- **Note timing** — if a step takes time, note it (e.g., "email sends, may take a moment")
- **Check for redirects** — use `list_network_requests` if you need to track API calls

## Success Criteria

- [ ] Every step has a before screenshot
- [ ] All form fields documented in data model table
- [ ] Decision points identified and documented
- [ ] Error states documented
- [ ] Complete spec file saved
- [ ] NavigationTips.md updated
