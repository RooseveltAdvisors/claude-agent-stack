# Placement Workflow

> **Trigger:** "where should this go", "user or project level", "should this be a skill or rule"

Helps decide where a specific piece of content belongs in the skill/rule/CLAUDE.md hierarchy.

## Steps

### Step 1: Identify the Content

Ask the user to describe or paste the content they want to place. Classify it:

| Content Type | Examples |
|---|---|
| **Constraint** | "Always use bun", "Never commit to main" |
| **Workflow** | "How to deploy", "Code review process" |
| **Domain knowledge** | "Our API uses X pattern", "Patient IDs format" |
| **Tool config** | "Run tests with uv run pytest" |
| **Style rule** | "Use snake_case for Python" |

### Step 2: Apply the Decision Tree

```
Q1: Can Claude figure this out from reading the code?
  → YES: Don't write it. Stop here.

Q2: Can a linter/hook/CI enforce this?
  → YES: Enforce via tool, not prose. Stop here.

Q3: Is it a repeatable multi-step workflow?
  → YES: Make it a Skill. Go to Step 3.
  → NO: It's a constraint/fact. Go to Step 4.

Step 3 (Skills):
  Q3a: Is the workflow logic the same across all your projects?
    → YES: User-level skill (~/.claude/skills/)
    → NO: Project-level skill (.claude/skills/)
  Q3b: Does the skill need project-specific constants?
    → YES: Put constants in project CLAUDE.md, keep logic in user-level skill

Step 4 (Constraints/Facts):
  Q4a: Does it apply to ALL your projects?
    → YES: ~/.claude/CLAUDE.md (keep it to one line)
  Q4b: Does it apply to specific file patterns only?
    → YES: .claude/rules/topic.md with paths: frontmatter
  Q4c: Is it always relevant in this project?
    → YES: Project CLAUDE.md
  Q4d: Is it personal preference, not team standard?
    → YES: CLAUDE.local.md
```

### Step 3: Output Recommendation

Format:

```markdown
## Placement Recommendation

**Content:** [summary]
**Type:** [constraint | workflow | domain knowledge | tool config | style rule]

**Recommended location:** `[exact file path]`
**Reason:** [one sentence citing the principle]

### Template
[Show the exact content to add, ready to copy-paste]
```

### Step 4: Check for Conflicts

Before placing:
- Grep existing CLAUDE.md files and rules for similar content → warn about duplication
- Check if a skill at the other level already covers this → recommend consolidation
- Verify the file won't exceed sizing guidelines (CLAUDE.md <100 lines, rules <50 lines)
