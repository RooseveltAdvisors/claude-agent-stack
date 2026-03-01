# WriteFromWork Workflow

> **Trigger:** "blog this", "blog this work", "turn this into a post", "write a post about what I just built"

Analyze recent work in the current repository and generate a blog post from it. This is the "vault-to-blog" pipeline — it turns engineering achievements into narrative content.

## Prerequisites

Read `WritingGuide.md` in the BlogWriter skill directory for voice, structure, and constraints.

## Steps

### Step 1: Analyze Recent Work

```bash
# Recent commits
git log --oneline -20

# What changed recently
git diff HEAD~5..HEAD --stat

# If user specifies a range or feature, scope to that
git log --oneline --all --grep="feature-keyword" -20
```

Read the actual implementation files in depth — not just the diff stats. Open the changed files and understand the code well enough to explain it to someone who has never seen it. Extract:
- **What** was built (architecture, key design decisions)
- **Why** it was built (the problem it solves, real-world context)
- **Results** (metrics, improvements, before/after)
- **Lessons learned** (what surprised you, what would you do differently)

If the user specifies a topic or feature, focus on relevant commits and files. Otherwise use the most significant recent body of work.

**This is the most important step** — post quality depends on understanding the work deeply enough to explain it conversationally, not just listing what changed.

### Step 2: Identify the Narrative

Every good technical post has a story arc. Extract one:

| Arc Type | Pattern | Example |
|---|---|---|
| **Problem → Solution** | "X was broken, here's how I fixed it" | Performance optimization, bug hunts |
| **Challenge → Discovery** | "I tried A, learned B, built C" | Unexpected technical insights |
| **Before → After** | "Here's what changed and why it matters" | Refactors, migrations, new features |
| **Question → Answer** | "Everyone asks X, here's what I found" | Research-driven posts |

Pick the strongest arc and proceed directly to drafting. Do NOT pause for user approval — run the full pipeline autonomously.

### Step 3: Draft the Post

**You MUST read `WritingGuide.md` in the BlogWriter skill directory before writing.** It contains the frontmatter template, structure pattern, required elements, and HIPAA guardrails. Do not skip this.

Write the full post following WritingGuide.md:
- First person as Jon
- Lead with the problem (keep it technical — no implied harm to end users)
- Show real code from the actual work (1-2 key blocks, not a tutorial)
- Include a metrics table (before/after, comparisons)
- 80-120 lines
- Place `{/* truncate */}` after the opening hook
- Apply HIPAA guardrails unconditionally for work-derived posts (they originate from real systems)

### Step 4: Proceed Directly to Publish

Do NOT pause for user review — proceed autonomously to the **Publish** workflow. The full pipeline (write → image → build → deploy → verify) runs end-to-end without user intervention.

If the user explicitly requests review ("let me see it first", "hold on"), then pause. Otherwise, keep going.
