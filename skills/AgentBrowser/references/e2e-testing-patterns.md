# E2E Testing Patterns

Best practices and workarounds for reliable end-to-end browser testing.

## Fallback Strategy: JavaScript Eval

When ref-based clicks fail (common with dynamic pages), use JavaScript eval as fallback:

```bash
# Ref-based click fails
agent-browser click @e1  # May fail on dynamic pages

# JavaScript fallback
agent-browser eval "document.querySelector('button.submit')?.click(); 'clicked'"
```

## Form Filling Patterns

### Standard Fields
```bash
agent-browser fill @e1 "value"  # Works for simple inputs
```

### Special Characters in Passwords
Password fields with special characters (`$`, `%`, `!`, `^`) may fail with `fill`:

```bash
# Use JavaScript for reliable password entry
agent-browser eval "
document.querySelector('input[type=\"password\"]').value = 'complex$password!';
'Set';
"
```

### Auto-Advancing Forms (Numpad/Phone Input)
For forms that auto-submit after a certain number of digits:

```bash
# Click numpad buttons with small delays
agent-browser click @e3 && sleep 0.2 && agent-browser click @e4 && ...

# Or use JavaScript for faster entry
agent-browser eval "
document.getElementById('phone').value = '5551234567';
document.getElementById('phone').dispatchEvent(new Event('input', { bubbles: true }));
"
```

### Multi-Step Form Flows
```bash
# Fill fields via JavaScript
agent-browser eval "
document.getElementById('first_name').value = 'Test';
document.getElementById('last_name').value = 'User';
// Dispatch events to trigger validation
document.getElementById('first_name').dispatchEvent(new Event('input', { bubbles: true }));
document.getElementById('last_name').dispatchEvent(new Event('input', { bubbles: true }));
'Fields filled';
"

# Submit form directly
agent-browser eval "document.querySelector('form')?.submit(); 'submitted'"
```

## Navigation Verification

Always verify navigation after clicks/submits:

```bash
# Wait and check location
sleep 2 && agent-browser get url && agent-browser get title
```

## Error Detection

### Check Browser Console
```bash
# Clear console first for clean output
agent-browser console --clear

# Perform action
agent-browser click @e1

# Check for errors
sleep 2 && agent-browser console
```

### Check API Responses
```bash
agent-browser eval "
fetch('/api/endpoint', { method: 'POST', body: JSON.stringify(data) })
  .then(r => r.text().then(t => 'Status: ' + r.status + ', Body: ' + t.substring(0, 200)))
  .catch(e => 'Error: ' + e.message)
"
```

## HTTPS and Proxy Issues

### Self-Signed Certificates
```bash
# Close browser first, then reopen with flag
agent-browser close
agent-browser --ignore-https-errors open https://localhost:8443
```

### 502 Bad Gateway Errors
When Flask returns 200 but browser sees 502:
- This is a **proxy/infrastructure issue** (Cloudflare, nginx)
- Verify Flask logs show 200 status
- Test directly against localhost to confirm app works
- Report as infrastructure issue, not application bug

## Session Management

### Check Session State
```bash
agent-browser eval "
fetch('/api/session')
  .then(r => r.json())
  .then(d => JSON.stringify(d, null, 2))
"
```

### Maintain Session Across Pages
Browser sessions persist automatically. If session is lost:
- Server may have restarted (session data cleared)
- Restart the flow from the beginning

## Common Pitfalls

| Issue | Solution |
|-------|----------|
| Click does nothing | Use JavaScript eval fallback |
| Password field empty | Set via JavaScript, not fill command |
| Form doesn't submit | Use `form.submit()` via eval |
| Navigation not detected | Add `sleep 2` before checking URL |
| Special chars escaped | Use single quotes or escape in JavaScript |
| Auto-submit too fast | Add delays between numpad clicks |
| Refs invalidated | Re-snapshot after any DOM change |

## Kiosk Flow Pattern (Multi-Step Registration)

```bash
# 1. Start at welcome page
agent-browser open "https://example.com/kiosk/welcome"

# 2. Navigate to check-in (direct navigation often more reliable)
agent-browser open "https://example.com/kiosk/check-in"

# 3. Enter phone number via numpad
agent-browser snapshot -i
# Click numpad buttons or use JavaScript

# 4. Fill demographics via JavaScript
agent-browser eval "
document.getElementById('first_name').value = 'Test';
document.getElementById('last_name').value = 'User';
document.querySelector('form').submit();
"

# 5. Verify navigation after each step
sleep 2 && agent-browser get url

# 6. Continue through flow...
```

## Debugging Failed Tests

1. **Take screenshot**: `agent-browser screenshot debug.png`
2. **Check console**: `agent-browser console`
3. **Get full snapshot**: `agent-browser snapshot` (not just `-i`)
4. **Check server logs**: Verify backend received/processed request
5. **Test via localhost**: Bypass proxy to isolate infrastructure issues
