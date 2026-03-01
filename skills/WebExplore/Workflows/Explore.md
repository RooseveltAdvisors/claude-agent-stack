# Explore Workflow

> **Trigger:** "explore [site/page]", "navigate to", "open website"

Systematic exploration of any website or page: navigate, snapshot, screenshot, document.

## Prerequisites

1. Chrome DevTools MCP must be running (use ChromeMCP skill if not)
2. Know the target URL or navigation path
3. Confirm output directory (default: `.agent/web-explore/`)

## Input Parameters

- **url:** Target URL to navigate to
- **page_name:** Short name for this page (used in file names, e.g., "dashboard", "settings")
- **output_dir:** Where to save screenshots and docs (default: `.agent/web-explore/`)

## Steps

### Step 1: Check NavigationTips.md

If `NavigationTips.md` exists in the output directory, read it for site-specific tips:
- Known navigation quirks
- Login requirements
- Elements that behave unexpectedly
- Shortcuts discovered previously

### Step 2: Navigate to URL

```
navigate_page type: "url", url: "[url]"
```

Wait for page to fully load:
```
wait_for text: "[any expected text on the page, e.g., page title or nav item]"
```

### Step 3: Take Snapshot (Assess State)

```
take_snapshot
```

Review snapshot to understand:
- Is the page fully loaded?
- Are there any dialogs, modals, or overlays?
- What are the main navigation areas?
- What interactive elements are visible?

**If login wall or unexpected page:** document the blocker, check NavigationTips.md for auth patterns, or ask user for credentials.

### Step 4: Take Overview Screenshot

```
take_screenshot filePath: "[output_dir]/screenshots/[page_name]-overview.png"
```

### Step 5: Document Structure

Based on the snapshot, document what you see:

```markdown
## Page: [Page Name]

**URL:** [url]
**Date:** [YYYY-MM-DD]

### Navigation
- [Top nav items]
- [Side nav items]
- [Breadcrumbs]

### Main Content Areas
- [Area 1: description]
- [Area 2: description]

### Action Buttons
- **[Button]** — [What it does]

### Key Data Displayed
- [Data point 1]
- [Data point 2]
```

### Step 6: Explore Interactive Elements

For each major section:

1. **Tabs:** Click each, wait, screenshot, document differences
2. **Dropdowns:** Click to open, snapshot options, document choices
3. **Expandable sections:** Expand ONE representative, screenshot, note the pattern
4. **Forms:** Document all fields (label, type, required, validation) without filling
5. **Modals/dialogs:** Open if safe/reversible, screenshot, Cancel to close

Naming convention for screenshots:
- `[page_name]-[section]-[state].png`
- Examples: `dashboard-sidebar.png`, `settings-form-open.png`

### Step 7: Save Spec File

Create/update: `[output_dir]/[page_name]-spec.md`

Use this template:

```markdown
# [Site/App] — [Page Name] Interface

**Document Date:** YYYY-MM-DD
**URL:** [url]
**Page Name:** [page_name]

## Screenshots

- Overview: `screenshots/[page_name]-overview.png`
- [Additional]: `screenshots/[page_name]-[detail].png`

## Navigation Path

**To Access:**
1. [Step 1]
2. [Step 2]

## Interface Components

### [Section Name]

**Screenshot:** `screenshots/[...].png`

**Buttons:**
- **[Button]** — [What it does]

**Form Fields:**
| Field | Type | Required | Validation | Default |
|-------|------|----------|------------|---------|
| ...   | ...  | ...      | ...        | ...     |

## Key Workflows

1. [Workflow name]
   - Step 1
   - Step 2
   - Result

## Notes

- [Quirk 1]
- [Quirk 2]
```

### Step 8: Update NavigationTips.md

If you discovered anything new about this site, add it:

```markdown
## [Site/Page Name]

**Last Updated:** YYYY-MM-DD

**Access Pattern:**
[How to reliably reach this page]

**Gotchas:**
- [Problem and solution]

**Time-Savers:**
- [Shortcut or tip]
```

## Error Recovery

| Problem | Recovery |
|---------|----------|
| Page didn't load | `take_snapshot` → check URL → retry navigate |
| Unexpected modal | Screenshot it → close it (Cancel/Escape) → continue |
| Login required | Note in NavigationTips.md → ask user for auth |
| Element not found | Re-snapshot → element UIDs change after navigation |
| Action had no effect | Wait 2s → re-snapshot → check if state changed |

## Success Criteria

- [ ] Overview screenshot saved
- [ ] All major sections documented
- [ ] Navigation path clearly recorded
- [ ] Spec file created/updated
- [ ] NavigationTips.md updated with new discoveries
- [ ] Browser left in clean state (no open modals)
