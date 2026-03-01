---
name: VideoToSpec
description: Generates comprehensive specification documents from video demonstrations. USE WHEN user asks to "create spec from video" OR "analyze demo video" OR "document product from Loom/YouTube". Navigates video, captures screenshots, and writes detailed feature documentation.
---

# VideoToSpec

Automates the process of creating comprehensive product specifications from video demonstrations (Loom, YouTube, Vimeo, etc.).

## Workflow Routing

| Workflow | Trigger | File |
|----------|---------|------|
| **CaptureVideoSpec** | "create spec from video", "analyze video", "document from Loom" | `Workflows/CaptureVideoSpec.md` |

## Examples

**Example 1: Create spec from Loom demo**
```
User: "Create a spec from this Loom video: https://www.loom.com/share/..."
→ Invokes CaptureVideoSpec workflow
→ Navigates to video, maximizes player
→ Captures screenshots at key timestamps
→ Generates comprehensive specification document
```

**Example 2: Document product from YouTube**
```
User: "Analyze this product demo and create a spec: https://youtube.com/watch?v=..."
→ Invokes CaptureVideoSpec workflow
→ Uses transcript to identify key features
→ Captures UI screenshots
→ Writes detailed feature documentation
```

**Example 3: Compare products from multiple videos**
```
User: "Create specs for these two competing products and compare them"
→ Invokes CaptureVideoSpec workflow for each video
→ Generates individual specs
→ Creates comparison section
```
