# DocumentPage Workflow

> **Trigger:** "document this page", "capture interface", "screenshot and document"

Comprehensive documentation of a specific page: all UI elements, data fields, screenshots, and generated spec.

## Prerequisites

- Chrome DevTools MCP running with the target page already open (or URL provided)
- Know the page name for file naming

## Input Parameters

- **page_name:** Short identifier for file naming (e.g., "user-profile", "order-form")
- **output_dir:** Output directory (default: `.agent/web-explore/`)
- **url:** Optional — navigate here first if not already on the page

## Steps

### Step 1: Navigate (if URL provided)

```
navigate_page type: "url", url: "[url]"
wait_for text: "[expected page content]"
```

### Step 2: Full-Page Screenshot

```
take_screenshot filePath: "[output_dir]/screenshots/[page_name].png", fullPage: true
```

### Step 3: Snapshot for Element Inventory

```
take_snapshot
```

Inventory all elements:
- Navigation items (tabs, breadcrumbs, sidebar links)
- Action buttons (primary, secondary, destructive)
- Form fields (inputs, selects, checkboxes, radios, textareas)
- Data display (tables, lists, cards, charts)
- Status indicators (badges, alerts, progress bars)

### Step 4: Explore Interactive Elements

**Order of operations:**

1. **Top-level tabs** — click each, screenshot, note differences
2. **Sub-tabs or secondary nav** — same approach
3. **Expandable sections** — open ONE representative, screenshot pattern
4. **Action buttons** — document label + action; click only if reversible (Cancel immediately after)
5. **Form fields** — click into ONE of each type to see behavior (tooltip, options, validation)
6. **Dropdowns/selects** — open to capture options, snapshot, close

Screenshot naming:
```
[page_name]-[feature]-[state].png
Examples:
  user-profile-edit-modal.png
  order-form-status-dropdown.png
  dashboard-chart-tooltip.png
```

### Step 5: Build Data Model Table

For every form field or data attribute found:

```markdown
| Field Name | Type | Required | Options / Validation | Default | Notes |
|------------|------|----------|----------------------|---------|-------|
| Email | text | Yes | Valid email format | — | Used for login |
| Status | select | Yes | Active, Inactive, Pending | Active | — |
| Created At | date | No | Read-only | Auto | — |
```

### Step 6: Generate Spec File

Save to: `[output_dir]/[page_name]-spec.md`

```markdown
# [App/Site] — [Page Name]

**Date:** YYYY-MM-DD
**URL:** [url]

## Screenshots

| Screenshot | Description |
|------------|-------------|
| `screenshots/[page_name].png` | Full page overview |
| `screenshots/[page_name]-[feature].png` | [Detail description] |

## Page Purpose

[1-2 sentences: what this page does and who uses it]

## Navigation

**To Access:**
1. [Step 1]
2. [Step 2]

## Interface Layout

### [Section 1]

[Description of this section's purpose]

**Elements:**
- **[Button/Link]** — [What it does]

**Fields:**
[Data model table for this section]

### [Section 2]

[Continue...]

## Interaction Patterns

**[Pattern Name] (e.g., Edit Record):**
1. [Step 1]
2. [Step 2]
3. Result: [What happens]

## Gotchas & Notes

- [Anything unusual or worth noting]
```

### Step 7: Update NavigationTips.md

Add/update entry for this page in `[output_dir]/NavigationTips.md`.

## Quality Checklist

- [ ] Full-page screenshot captured
- [ ] All tabs/sections explored and screenshotted
- [ ] Complete data model table created
- [ ] All button actions documented
- [ ] Navigation path documented step-by-step
- [ ] Spec file saved in correct location
- [ ] Browser left clean (no open modals or unsaved forms)
