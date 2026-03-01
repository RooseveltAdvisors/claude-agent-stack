# Interact Workflow

> **Trigger:** "click", "fill form", "interact with", "submit", "automate", "do [action] on website"

Perform specific browser interactions: click elements, fill forms, submit data, extract information.

## Prerequisites

- Chrome DevTools MCP running
- Target page loaded or URL provided
- Clear description of what to interact with and the desired outcome

## Input Parameters

- **action:** What to do (click, fill, submit, extract, etc.)
- **target:** What to interact with (element description, form name, button label)
- **url:** Optional — navigate here first
- **data:** For forms — key/value pairs to fill in

## Core Interaction Patterns

### Pattern A: Click an Element

```
# Step 1: Get current state
take_snapshot  ← identifies all element UIDs

# Step 2: Find target element in snapshot
# Look for button/link by label, role, or position

# Step 3: Click it
click uid: "[uid from snapshot]"

# Step 4: Verify result
wait_for text: "[expected response text]"
take_snapshot  ← confirm new state
take_screenshot filePath: "[output_dir]/screenshots/[action]-result.png"
```

### Pattern B: Fill a Form

```
# Step 1: Navigate to form
navigate_page type: "url", url: "[url]"
take_snapshot  ← get field UIDs

# Step 2: Fill fields (use fill_form for multiple at once)
fill_form elements: [
  { uid: "[field1_uid]", value: "[value1]" },
  { uid: "[field2_uid]", value: "[value2]" }
]

# Step 3: Verify fills registered
take_snapshot

# Step 4: Submit
click uid: "[submit_button_uid]"
wait_for text: "[success indicator]"
take_screenshot filePath: "[output_dir]/screenshots/form-result.png"
```

### Pattern C: Select from Dropdown

```
take_snapshot  ← get select UID
fill uid: "[select_uid]", value: "[option value]"
take_snapshot  ← confirm selection
```

### Pattern D: Handle a Modal/Dialog

```
# To open:
click uid: "[trigger_uid]"
wait_for text: "[modal title or content]"
take_screenshot filePath: "[output_dir]/screenshots/modal-open.png"

# To close without saving:
press_key key: "Escape"
# OR click Cancel button

# To close with save:
click uid: "[save_button_uid]"
wait_for text: "[confirmation]"
```

### Pattern E: Extract Data from Page

```
take_snapshot  ← review page structure
# Use evaluate_script for structured data extraction:
evaluate_script function: "() => {
  // Example: extract table data
  const rows = document.querySelectorAll('table tr');
  return Array.from(rows).map(r => r.innerText);
}"
```

### Pattern F: Navigate Through Pagination

```
# Page through a list:
while has_next_page:
  take_screenshot filePath: "[output_dir]/screenshots/page-[N].png"
  # Extract data from this page
  click uid: "[next_page_button_uid]"
  wait_for text: "[content indicator for next page]"
  take_snapshot
```

## Interaction Guardrails

**Always do before interacting:**
- `take_snapshot` to get fresh UIDs (UIDs change after navigation)
- Confirm you found the right element (check its label/role in snapshot)

**Never do:**
- Submit destructive actions (delete, archive, send) without explicit user confirmation
- Fill real personal data into unknown forms
- Click "Confirm Delete" or equivalent without a user checkpoint

**If unsure about an action:**
- Screenshot the current state
- Describe what you see to the user
- Ask for confirmation before proceeding

## Common Troubleshooting

| Issue | Solution |
|-------|----------|
| Element UID not found | Re-`take_snapshot` — UIDs are session-specific |
| Click had no effect | Wait 1-2s → re-snapshot → check if state changed |
| Form fill not registering | Try `fill` on the specific input UID (not parent) |
| Page not loading | `wait_for` with longer timeout, or check `list_network_requests` |
| Dialog blocking interaction | Handle it first with `handle_dialog` or screenshot + close |
| JavaScript needed | Use `evaluate_script` for operations not possible via DOM |

## Output

After interactions, document what happened:

```markdown
## Interaction Log: [Date]

**URL:** [url]
**Action:** [What was done]
**Inputs:** [Data provided]
**Result:** [What happened]
**Screenshot:** `screenshots/[action]-result.png`
**Notes:** [Anything unexpected]
```

Save to `[output_dir]/interaction-log.md` for reference.
