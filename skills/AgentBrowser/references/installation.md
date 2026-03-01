# Installation

**Source:** https://github.com/vercel-labs/agent-browser

## npm (recommended)

```bash
npm install -g agent-browser
agent-browser install  # Download Chromium
```

## From Source

```bash
git clone https://github.com/vercel-labs/agent-browser
cd agent-browser
pnpm install
pnpm build
pnpm build:native   # Requires Rust (https://rustup.rs)
pnpm link --global  # Makes agent-browser available globally
agent-browser install
```

## Linux Dependencies

On Linux, install system dependencies:

```bash
agent-browser install --with-deps
# or manually: npx playwright install-deps chromium
```

## Custom Browser Executable

Use a custom browser executable instead of the bundled Chromium:

```bash
# Via flag
agent-browser --executable-path /path/to/chromium open example.com

# Via environment variable
AGENT_BROWSER_EXECUTABLE_PATH=/path/to/chromium agent-browser open example.com
```

### Serverless (Vercel/AWS Lambda)

```typescript
import chromium from '@sparticuz/chromium';
import { BrowserManager } from 'agent-browser';

export async function handler() {
  const browser = new BrowserManager();
  await browser.launch({
    executablePath: await chromium.executablePath(),
    headless: true,
  });
  // ... use browser
}
```

## Platforms

| Platform | Binary | Fallback |
|----------|--------|----------|
| macOS ARM64 | Native Rust | Node.js |
| macOS x64 | Native Rust | Node.js |
| Linux ARM64 | Native Rust | Node.js |
| Linux x64 | Native Rust | Node.js |
| Windows x64 | Native Rust | Node.js |

## Architecture

agent-browser uses a client-daemon architecture:

1. **Rust CLI** (fast native binary) - Parses commands, communicates with daemon
2. **Node.js Daemon** - Manages Playwright browser instance
3. **Fallback** - If native binary unavailable, uses Node.js directly

The daemon starts automatically on first command and persists between commands for fast subsequent operations.

**Browser Engine:** Uses Chromium by default. The daemon also supports Firefox and WebKit via the Playwright protocol.
