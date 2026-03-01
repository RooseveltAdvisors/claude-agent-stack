# WriteFromTopic Workflow

> **Trigger:** "write a blog post about X", "blog about X", "draft a post on X"

Write a blog post from a user-provided topic. The topic may or may not relate to the current repo.

## Prerequisites

Read `WritingGuide.md` in the BlogWriter skill directory for voice, structure, and constraints.

## Steps

### Step 1: Research the Topic

Gather material depending on the topic source:

**If the topic relates to code in the current repo:**
```bash
# Search for relevant files
grep -r "topic-keyword" --include="*.ts" --include="*.py" -l
# Read key implementation files
# Check git log for related commits
git log --oneline --all --grep="topic-keyword" -20
```

**If the topic is general / external:**
- Use web search to gather current facts, stats, and context
- Check if Jon has prior work on this topic in the blog repo

**If the user provides reference material:**
- Read all provided files, URLs, or context first

**Goal:** Understand the topic deeply enough to write with authority and specifics — not surface-level summaries.

### Step 2: Outline

Internally decide on the outline. Do NOT pause for user approval — proceed autonomously unless the user explicitly asks for outline review.

Determine:
- **Title:** Compelling, communicates the key insight
- **Slug:** descriptive-kebab-case
- **Tags:** 3-5 relevant tags
- **Hook:** The opening problem/situation
- **Insight:** The key discovery or turning point
- **Solution:** What was built / how it works
- **Results:** Metrics, before/after
- **Takeaways:** 2-3 generalizable lessons

### Step 3: Draft the Post

**You MUST read `WritingGuide.md` in the BlogWriter skill directory before writing.** It contains the frontmatter template, structure pattern, required elements, and HIPAA guardrails. Do not skip this.

Write the full post following WritingGuide.md:
- First person as Jon
- Lead with the problem
- 80-120 lines
- Include at least one table and one code block
- Place `{/* truncate */}` after the opening hook
- Apply HIPAA guardrails for ANY topic touching healthcare, patient data, clinical systems, or the Portal

Use the frontmatter template from WritingGuide.md.

### Step 4: Proceed Directly to Publish

Do NOT pause for user review — proceed autonomously to the **Publish** workflow. The full pipeline (write → image → build → deploy → verify) runs end-to-end without user intervention, matching the PortalBlogFromVault reference skill.

If the user explicitly requests review ("let me see it first", "hold on"), then pause. Otherwise, keep going.
