# BrowseAndInteract Workflow

> **Trigger:** "browse website", "navigate to", "open page", "go to URL"

## Purpose

Navigate to web pages and interact with elements using the agent-browser CLI.

## Workflow Steps

### Step 1: Open the Target URL

```bash
agent-browser open <url>
```

If no protocol specified, `https://` is auto-prepended.

### Step 2: Take a Snapshot

```bash
agent-browser snapshot -i
```

This returns interactive elements with refs like `@e1`, `@e2`, etc.

### Step 3: Identify Target Elements

Review the snapshot output to find the element refs you need to interact with.

### Step 4: Perform Interactions

Use the appropriate command with the element ref:

```bash
agent-browser click @e1         # Click
agent-browser fill @e2 "text"   # Fill input
agent-browser hover @e3         # Hover
agent-browser select @e4 "opt"  # Select dropdown
```

### Step 5: Re-snapshot After Changes

After navigation or significant DOM changes:

```bash
agent-browser snapshot -i
```

Element refs may change after page updates.

## Tips

- Always use `snapshot -i` to get fresh element refs
- Use `--headed` flag to see the browser window for debugging
- Use `wait` commands to ensure page is ready before interacting
- Use `--session` for parallel browser instances
