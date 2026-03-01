# ScreenCapture Workflow

> **Trigger:** "screenshot", "capture page", "save PDF", "record video"

## Purpose

Capture screenshots, PDFs, and video recordings of web pages.

## Screenshot Workflow

### Basic Screenshot

```bash
agent-browser open <url>
agent-browser screenshot output.png
```

### Full Page Screenshot

```bash
agent-browser screenshot --full fullpage.png
```

### Element Screenshot

```bash
agent-browser snapshot -i
agent-browser screenshot @e1   # Screenshot specific element
```

## PDF Workflow

```bash
agent-browser open <url>
agent-browser pdf output.pdf
```

## Video Recording Workflow

### Step 1: Navigate to Starting Point

```bash
agent-browser open <url>
```

### Step 2: Start Recording

```bash
agent-browser record start ./demo.webm
```

### Step 3: Perform Actions

```bash
agent-browser snapshot -i
agent-browser click @e1
agent-browser fill @e2 "text"
# ... more interactions
```

### Step 4: Stop Recording

```bash
agent-browser record stop
```

## Tips

- Use `--headed` to see the browser while capturing
- For high-quality captures, set viewport: `agent-browser set viewport 1920 1080`
- Use `wait --load networkidle` before capturing to ensure page is fully loaded
- Video recording creates a fresh context but preserves cookies/storage
