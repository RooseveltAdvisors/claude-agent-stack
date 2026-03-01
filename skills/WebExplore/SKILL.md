---
name: WebExplore
description: Systematic UI exploration and documentation using headed Chrome (visible browser). USE WHEN documenting an interface into a spec, capturing a multi-step user flow, or exploring an unfamiliar UI to understand its structure. Run ChromeMCP first for authenticated sites. NOT for quick automation tasks (use AgentBrowser), NOT for writing scripts (use Browser), NOT just launching a browser (use ChromeMCP).
---

# WebExplore

Systematic browser automation for exploring, documenting, and interacting with any website using headed Chrome via Chrome DevTools MCP. Distilled from NextGenExplore lessons learned.

## Workflow Routing

| Workflow | Trigger | File |
|----------|---------|------|
| **Explore** | "explore [site/page]", "navigate to", "open website" | `Workflows/Explore.md` |
| **DocumentPage** | "document this page", "capture interface", "screenshot and document" | `Workflows/DocumentPage.md` |
| **CaptureFlow** | "capture flow", "document workflow", "record steps" | `Workflows/CaptureFlow.md` |
| **Interact** | "click", "fill form", "interact with", "submit", "automate" | `Workflows/Interact.md` |

## Examples

**Example 1: Explore a website**
```
User: "Explore the dashboard at app.example.com"
→ Invokes Explore workflow
→ Takes snapshot to see current state
→ Takes overview screenshot
→ Documents all navigation, buttons, sections
→ Saves findings to output directory
```

**Example 2: Document a specific page**
```
User: "Document the settings page"
→ Invokes DocumentPage workflow
→ Takes full screenshot
→ Explores all tabs, dropdowns, forms
→ Generates markdown spec with data model table
→ Saves screenshot + spec file
```

**Example 3: Capture a multi-step workflow**
```
User: "Capture the signup flow on the website"
→ Invokes CaptureFlow workflow
→ Starts at entry point
→ Screenshots each step
→ Documents state transitions and form fields
→ Generates step-by-step spec
```

**Example 4: Automate a browser interaction**
```
User: "Fill out the contact form and submit"
→ Invokes Interact workflow
→ Navigates to form
→ Takes snapshot to identify element UIDs
→ Fills fields, clicks buttons
→ Screenshots result
```

## Key Principles (Lessons from NextGenExplore)

- **Snapshot before acting** — always `take_snapshot` first to get element UIDs
- **Wait after navigation** — use `wait_for` to confirm page loaded before acting
- **Screenshot for documentation** — use `take_screenshot` with a `filePath` to save to disk
- **One click at a time** — don't batch clicks; verify state between interactions
- **Close modals cleanly** — always Cancel/Close before navigating away
- **Document discoveries** — update `NavigationTips.md` with any site-specific lessons
- **Error recovery** — if navigation fails, re-snapshot and reassess before retrying

## Output Convention

By default, save output to `.agent/web-explore/`:
- `screenshots/[page-name].png` — UI screenshots
- `[page-name]-spec.md` — Interface specifications
- `NavigationTips.md` — Lessons learned per site
