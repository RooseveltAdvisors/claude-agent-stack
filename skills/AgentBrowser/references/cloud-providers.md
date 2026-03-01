# Cloud Browser Providers

Use cloud browser infrastructure when running in environments where a local browser isn't feasible (serverless, CI/CD, etc.).

## Browserbase

[Browserbase](https://browserbase.com) provides remote browser infrastructure for agentic browsing agents.

```bash
export BROWSERBASE_API_KEY="your-api-key"
export BROWSERBASE_PROJECT_ID="your-project-id"
agent-browser -p browserbase open https://example.com
```

Or via environment variables:

```bash
export AGENT_BROWSER_PROVIDER=browserbase
export BROWSERBASE_API_KEY="your-api-key"
export BROWSERBASE_PROJECT_ID="your-project-id"
agent-browser open https://example.com
```

Get credentials from the [Browserbase Dashboard](https://browserbase.com/overview).

## Browser Use

[Browser Use](https://browser-use.com) provides cloud browser infrastructure for AI agents.

```bash
export BROWSER_USE_API_KEY="your-api-key"
agent-browser -p browseruse open https://example.com
```

Or via environment variables:

```bash
export AGENT_BROWSER_PROVIDER=browseruse
export BROWSER_USE_API_KEY="your-api-key"
agent-browser open https://example.com
```

Get your API key from the [Browser Use Cloud Dashboard](https://cloud.browser-use.com/settings?tab=api-keys). Free credits available.

## Kernel

[Kernel](https://www.kernel.sh) provides cloud browser infrastructure with stealth mode and persistent profiles.

```bash
export KERNEL_API_KEY="your-api-key"
agent-browser -p kernel open https://example.com
```

Or via environment variables:

```bash
export AGENT_BROWSER_PROVIDER=kernel
export KERNEL_API_KEY="your-api-key"
agent-browser open https://example.com
```

### Kernel Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `KERNEL_HEADLESS` | Run browser in headless mode (`true`/`false`) | `false` |
| `KERNEL_STEALTH` | Enable stealth mode to avoid bot detection (`true`/`false`) | `true` |
| `KERNEL_TIMEOUT_SECONDS` | Session timeout in seconds | `300` |
| `KERNEL_PROFILE_NAME` | Browser profile name for persistent cookies/logins | (none) |

**Profile Persistence:** When `KERNEL_PROFILE_NAME` is set, the profile will be created if it doesn't exist. Cookies, logins, and session data are automatically saved back.

Get your API key from the [Kernel Dashboard](https://dashboard.onkernel.com).

## CDP Mode

Connect to an existing browser via Chrome DevTools Protocol:

```bash
# Start Chrome with: google-chrome --remote-debugging-port=9222

# Connect once, then run commands without --cdp
agent-browser connect 9222
agent-browser snapshot
agent-browser close

# Or pass --cdp on each command
agent-browser --cdp 9222 snapshot

# Connect to remote browser via WebSocket URL
agent-browser --cdp "wss://your-browser-service.com/cdp?token=..." snapshot
```

The `--cdp` flag accepts:
- A port number (e.g., `9222`) for local connections via `http://localhost:{port}`
- A full WebSocket URL (e.g., `wss://...` or `ws://...`) for remote browser services

This enables control of:
- Electron apps
- Chrome/Chromium instances with remote debugging
- WebView2 applications
- Any browser exposing a CDP endpoint
