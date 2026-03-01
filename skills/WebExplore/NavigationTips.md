# WebExplore Navigation Tips

A living document of lessons learned. Copy this to your project's output directory (`.agent/web-explore/NavigationTips.md`) and update it as you explore.

---

## General Browser Automation Principles

**Always snapshot before clicking:**
- Element UIDs change after every navigation
- Never reuse UIDs from a previous snapshot

**Wait after navigation:**
- Use `wait_for text: "[expected text]"` after every `navigate_page`
- Don't assume the page loaded; verify with snapshot

**Handle dialogs immediately:**
- If a dialog appears, deal with it before continuing
- Use `handle_dialog action: "accept"` or `"dismiss"`
- Or take_snapshot to find the close button UID

**Close things cleanly:**
- Always Cancel/Escape out of modals before navigating away
- Leaving forms open can cause state issues on next visit

**Screenshot organization:**
- Use descriptive names: `[page]-[section]-[state].png`
- `fullPage: true` for full-page captures (good for long pages)

---

## Site-Specific Tips

<!-- Add per-site sections here as you explore. Example format:

## [Site Name] (e.g., app.example.com)

**Last Updated:** YYYY-MM-DD

**Login:**
- URL: [login url]
- If using ChromeMCP with profile copy, likely already logged in

**Navigation Quirks:**
- [Tip 1]
- [Tip 2]

**Gotchas:**
- [Problem] → [Solution]

**Time-Savers:**
- [Shortcut or tip]
-->

---

## Useful evaluate_script Snippets

**Get all text on page:**
```javascript
() => document.body.innerText
```

**Get all links:**
```javascript
() => Array.from(document.querySelectorAll('a')).map(a => ({ text: a.innerText, href: a.href }))
```

**Get table data:**
```javascript
() => {
  const headers = Array.from(document.querySelectorAll('thead th')).map(th => th.innerText);
  const rows = Array.from(document.querySelectorAll('tbody tr')).map(tr =>
    Array.from(tr.querySelectorAll('td')).map(td => td.innerText)
  );
  return { headers, rows };
}
```

**Get all form fields:**
```javascript
() => Array.from(document.querySelectorAll('input, select, textarea')).map(el => ({
  type: el.type || el.tagName.toLowerCase(),
  name: el.name,
  id: el.id,
  placeholder: el.placeholder,
  value: el.value,
  required: el.required
}))
```
