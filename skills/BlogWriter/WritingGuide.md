# Blog Writing Guide

Jon Roosevelt's voice, style, and constraints for blog posts on jonroosevelt.com.

## Voice & Tone

- **First person, conversational.** Write as Jon — a developer who builds technology to solve real problems.
- **Lead with the problem.** Open with a concrete, relatable engineering situation.
- **Show real numbers.** Accuracy percentages, time savings, error rates. Specifics build trust.
- **Include code, but sparingly.** One or two key code blocks that illustrate the core insight. Narrative, not tutorial.
- **Tables for comparisons.** Use markdown tables for before/after metrics, model comparisons, architecture overviews.
- **End with what you learned.** The takeaway should be generalizable — something the reader can apply to their own work.
- **Length: 80-120 lines.**
- **No emojis** unless the user explicitly requests them.

## Structure Pattern

```
1. Opening hook (the problem, 2-3 paragraphs)
   ![Alt text](/img/blog/YYYY-MM-DD-slug/hero-banner.jpg)
   {/* truncate */}
2. The insight / discovery (what changed your approach)
3. The solution (architecture, with a diagram or table)
4. Results (metrics, before/after comparison)
5. Production details (key design decisions, 3-5 bullets)
6. What I learned (2-3 generalizable takeaways)
7. Credits / citations footer (MANDATORY — see below)
```

### Required Elements

- Hero image in frontmatter (`image:`) AND inline right before `{/* truncate */}`
- `{/* truncate */}` marker after the opening hook (controls blog list preview)
- At least one markdown table
- At least one code block
- Credits / citations footer at the end (see Citations section below)

## Frontmatter Template

```yaml
---
slug: descriptive-kebab-case-slug
title: "Compelling Title That Communicates the Key Insight"
authors: [jon]
tags: [relevant, topic, tags, healthcare, ai, etc]
image: /img/blog/YYYY-MM-DD-slug/hero-banner.jpg
---
```

**MANDATORY:** Every post MUST include `image:` in frontmatter AND an actual hero image file. Always `.jpg` — the homepage `useBlogPosts.ts` hardcodes this extension.

## Citations & Credits (MANDATORY)

Every post MUST end with a credits/citations footer. Give credit to:

- **Tools used** — name the tool, link to its homepage or GitHub repo
- **Papers or research** — cite the paper title, authors, and link if available
- **Prior art / inspiration** — link to any techniques, frameworks, or approaches drawn from
- **Open-source projects** — link to the GitHub repo
- **AI assistance** — if Claude Code or another AI helped write, research, or build something in the post, say so clearly

Format:
```mdx
---

*Tools used: [Tool Name](https://link) by Author/Org, [Another Tool](https://link). Research: [Paper Title](https://link) by Author et al. Source code: [repo-name](https://github.com/...). Built with [Claude Code](https://claude.ai/download) by Anthropic.*
```

**Why this matters:** Intellectual honesty. If you're writing about a technique from a paper, credit the authors. If a tool made something possible, say which tool. Readers who want to reproduce your work need to know what you used. It also differentiates real engineering posts from generic AI-written content.

## HIPAA & Liability Guardrails (MANDATORY, NON-NEGOTIABLE)

These apply to ALL posts, especially those involving healthcare work:

1. **NEVER name the clinic, health system, or real staff/patients.** Use: "the clinic", "our portal", "a healthcare practice". Not the actual name.
2. **NEVER describe clinical harm or patient impact.** Frame problems technically: "the booking page returned errors", not "patients couldn't see their doctor".
3. **NEVER reveal PHI-adjacent details.** No real phone numbers, patient IDs, appointment counts, demographic details.
4. **NEVER describe security vulnerabilities in specific terms.** Say "input validation gaps", not "SQL injection in the patient search endpoint".
5. **NEVER mention specific compliance failures.** Frame as improvements: "we added comprehensive audit logging."
6. **Frame problems as engineering challenges, not operational failures.**
7. **Genericize the domain.** "A multi-tenant SaaS portal" is safer than "a patient-facing healthcare portal."

**Pre-publish self-check:** "Could a lawyer use any sentence in this post against us?" If yes, rewrite it.

## Personal Privacy & Security Guardrails (MANDATORY)

These apply to ALL posts to protect personal infrastructure from exposure:

1. **NEVER name specific machines.** Use generic descriptions: "the development server", "the production server", "the GPU workstation", "a remote machine". Never use actual hostnames or SSH aliases.
2. **NEVER reveal network topology.** No IP addresses, subnet ranges, firewall rules, port numbers, or descriptions of how machines are connected.
3. **NEVER reveal SSH usernames, paths, or access patterns.** Say "I SSH into the server" not `ssh user@your-server`.
4. **NEVER name the domain registrar, DNS provider, or SSL configuration details.** Say "behind a reverse proxy with TLS" not "Cloudflare origin cert with proxy off for LiveKit".
5. **NEVER describe the exact directory structure of production systems.** Generic paths like `~/app/` are fine; actual service paths are not.
6. **NEVER reveal which services run on which ports.** Keep it to "the web app", "the API server", "the media server".
7. **Genericize infrastructure.** Write for a reader building something similar — give them the pattern, not your specific config.

**The test:** "Could a threat actor use any sentence in this post to map my network or find an attack surface?" If yes, rewrite it.

## Hero Image Requirements

- Generated via the **Art skill** (Excalidraw hand-drawn aesthetic)
- Must be converted to `.jpg` (not `.png`)
- Placed in `static/img/blog/YYYY-MM-DD-slug/hero-banner.jpg`
- Referenced in TWO places:
  1. Frontmatter: `image: /img/blog/YYYY-MM-DD-slug/hero-banner.jpg`
  2. Inline: `![Alt text](/img/blog/YYYY-MM-DD-slug/hero-banner.jpg)` right before `{/* truncate */}`

## Lessons Learned from the BlogWriter Pipeline

Accumulated from real publishing runs — apply these every time:

### Research
- **Read existing posts before writing** — check the blog repo for posts that cover similar ground. Differentiate the angle, don't repeat content that already exists.
- **The existing post list is the best dedup tool.** Scan slugs and titles before outlining.

### Content & Privacy
- **Strip personal specifics before they hit the draft.** It's easy to reference a hostname or port number while writing quickly. Do a privacy pass before the hero image step.
- **Generic descriptions are more useful anyway.** "A remote GPU workstation" teaches the pattern better than a specific hostname does.
- **Credits should be specific, not vague.** "Built with AI" is lazy. Name the tool, version if relevant, and what it did.

### Publishing Pipeline
- **Write to the remote server, not local.** The blog repo lives on the remote server. Always SSH write, never write locally and scp.
- **Both hero image references must exist** — frontmatter `image:` AND inline `![...]()`. Missing either fails the gate check.
- **The homepage shows the 3 most recent posts by date.** If two posts share a date, both appear and displace older ones. Plan date assignment intentionally when publishing multiple posts.
- **Always run the 3-check gate** (image file exists, frontmatter has `image:`, inline tag exists) before the build. Skipping it causes build failures or broken homepage cards.
- **`bun run build` catches MDX errors.** Always run it before committing. A syntax error in MDX will build-fail silently if you only check the serve output.
- **Local serve check is mandatory.** The build can succeed but the homepage slug grep can fail if the post date isn't newest. Check `curl localhost:3333/ | grep slug`.
- **GitHub Pages takes 3-5 minutes** after push. Don't verify immediately — wait and then use AgentBrowser for the live check, not curl (AgentBrowser catches rendering issues curl misses).
- **The remote server may have `convert` (ImageMagick v6), not `magick` (v7).** Always use `convert`, not `magick`, unless you verify the version.
- **hero-banner must be `.jpg`.** The homepage `useBlogPosts.ts` hardcodes `.jpg`. A `.png` hero will silently break the homepage card image.
