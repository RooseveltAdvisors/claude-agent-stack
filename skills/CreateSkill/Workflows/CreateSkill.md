# CreateSkill Workflow

> **Trigger:** "create a new skill", "new skill for"

## Prerequisites

Before creating a skill, ensure you have read:
- `$PAI_DIR/skills/CORE/SkillSystem.md` - The authoritative structure guide

## Steps

### Step 1: Gather Requirements

Ask the user:
1. What is the skill's primary purpose?
2. What triggers should activate this skill?
3. What workflows does it need?

### Step 2: Create Directory Structure

```bash
# Create skill directory (TitleCase!)
mkdir -p $PAI_DIR/skills/[SkillName]/Workflows
mkdir -p $PAI_DIR/skills/[SkillName]/Tools
```

### Step 3: Create SKILL.md

Create `$PAI_DIR/skills/[SkillName]/SKILL.md`:

```markdown
---
name: [SkillName]
description: [What it does]. USE WHEN [trigger1] OR [trigger2] OR [trigger3].
---

# [SkillName]

[Brief description of the skill]

## Workflow Routing

| Workflow | Trigger | File |
|----------|---------|------|
| **[WorkflowName]** | "[trigger phrase]" | `Workflows/[WorkflowName].md` |

## Examples

**Example 1: [Use case]**
\`\`\`
User: "[Request]"
→ [What happens]
→ [Result]
\`\`\`
```

### Step 4: Create Workflows

For each workflow in the routing table, create a file in `Workflows/`:

```markdown
# [WorkflowName] Workflow

> **Trigger:** "[trigger phrase]"

## Steps

### Step 1: [First step]
[Instructions]

### Step 2: [Second step]
[Instructions]
```

### Step 5: Register the Skill

```bash
bun run $PAI_DIR/Tools/GenerateSkillIndex.ts
```

### Step 6: Verify

```bash
bun run $PAI_DIR/Tools/SkillSearch.ts [skill-name]
```

## Checklist

- [ ] Directory uses TitleCase (e.g., `RecipeManager`, not `recipe-manager`)
- [ ] YAML frontmatter has `name` and `description` with `USE WHEN`
- [ ] Workflow Routing table exists
- [ ] Examples section with 2-3 usage patterns
- [ ] Tools/ directory exists (even if empty)
- [ ] Skill is registered in index
