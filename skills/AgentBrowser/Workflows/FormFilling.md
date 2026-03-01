# FormFilling Workflow

> **Trigger:** "fill form", "submit form", "enter data", "complete form"

## Purpose

Automate form filling and submission using agent-browser.

## Workflow Steps

### Step 1: Navigate to the Form

```bash
agent-browser open <form-url>
```

### Step 2: Snapshot Interactive Elements

```bash
agent-browser snapshot -i
```

Identify form fields and their refs:
- `textbox "Email" [ref=e1]`
- `textbox "Password" [ref=e2]`
- `button "Submit" [ref=e3]`

### Step 3: Fill Form Fields

```bash
agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
```

For different field types:

```bash
agent-browser check @ref       # Checkboxes
agent-browser select @ref "v"  # Dropdowns
agent-browser upload @ref file # File uploads
```

### Step 4: Submit the Form

```bash
agent-browser click @e3
```

### Step 5: Wait for Response

```bash
agent-browser wait --load networkidle
# or
agent-browser wait --text "Success"
# or
agent-browser wait --url "**/confirmation"
```

### Step 6: Verify Result

```bash
agent-browser snapshot -i
```

## Tips

- Use `fill` to clear and type; use `type` to append text
- For multi-select: `agent-browser select @ref "a" "b" "c"`
- Save authentication state: `agent-browser state save auth.json`
- Load saved state: `agent-browser state load auth.json`
