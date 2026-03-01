---
name: BlogWriter
description: Write and publish blog posts to yourdomain.com. USE WHEN "write a blog post" OR "blog about" OR "publish blog" OR "blog this work" OR "turn this into a blog post" OR "draft a post". Analyzes work context, generates Docusaurus MDX posts with hero images, deploys to GitHub Pages.
---

# BlogWriter

General-purpose blog writing skill for yourdomain.com. Can generate posts from scratch on any topic, or analyze recent git work in the current repo to turn engineering achievements into polished narrative posts. Handles the full pipeline: research, writing, hero image generation, build verification, deployment, and live-site confirmation.

## Workflow Routing

| Workflow | Trigger | File |
|----------|---------|------|
| **WriteFromTopic** | "write a blog post about X", "blog about X" | `Workflows/WriteFromTopic.md` |
| **WriteFromWork** | "blog this", "blog this work", "turn this into a post" | `Workflows/WriteFromWork.md` |
| **Publish** | "publish the blog post", "push the post live" | `Workflows/Publish.md` |

**IMPORTANT:** WriteFromTopic and WriteFromWork automatically chain into Publish. The full pipeline runs end-to-end autonomously — do NOT pause between workflows. Publish can also be invoked standalone for a pre-written post.

## Examples

**Example 1: Blog about a topic**
```
User: "Write a blog post about how we built our FHIR integration"
→ Invokes WriteFromTopic workflow
→ Researches the topic (reads code, docs, web if needed)
→ Drafts post in Jon's voice, generates hero image
→ Asks user to review before publishing
```

**Example 2: Turn recent work into a post**
```
User: "Blog this" (from inside a repo after building a feature)
→ Invokes WriteFromWork workflow
→ Analyzes recent git commits and changed files
→ Extracts the narrative: problem → insight → solution → results
→ Drafts post, generates hero image, asks for review
```

**Example 3: Publish a drafted post**
```
User: "Publish the blog post"
→ Invokes Publish workflow
→ Writes post to remote blog repo via SSH
→ Generates/places hero image, runs build test
→ Commits, pushes, verifies live site
```

## Quick Reference

| Setting | Value |
|---|---|
| Blog repo (remote server) | `~/Documents/git/jon/your-org/your-blog-repo` |
| SSH host | `your-dev-server` |
| Post format | Docusaurus `.mdx` |
| Post directory | `blog/YYYY-MM-DD-slug/index.mdx` |
| Image directory | `static/img/blog/YYYY-MM-DD-slug/` |
| Author | `[jon]` |
| Site URL | `https://yourdomain.com/blog/<slug>` |
| Image format | `.jpg` only (homepage hardcodes this) |
