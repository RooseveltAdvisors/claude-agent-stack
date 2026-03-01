# ValidateSkill Workflow

> **Trigger:** "validate skill", "check skill structure"

## Purpose

Validates that a skill conforms to the required SkillSystem.md structure.

## Steps

### Step 1: Identify Skill to Validate

Ask user which skill to validate, or validate all skills.

### Step 2: Check Structure

For each skill, verify:

#### Directory Structure
- [ ] Skill directory uses TitleCase
- [ ] `SKILL.md` exists in root
- [ ] `Tools/` directory exists
- [ ] `Workflows/` directory exists (if workflows are referenced)

#### SKILL.md Content
- [ ] YAML frontmatter is present
- [ ] `name:` uses TitleCase
- [ ] `description:` is single line
- [ ] `description:` contains `USE WHEN` clause
- [ ] `## Workflow Routing` section exists (if workflows)
- [ ] `## Examples` section exists with 2+ examples

#### Naming Conventions
- [ ] All workflow files use TitleCase (e.g., `CreateItem.md`)
- [ ] All tool files use TitleCase (e.g., `ManageServer.ts`)

### Step 3: Report Results

```
📋 SUMMARY: Skill validation complete

✅ PASSED:
  - [SkillName]: All checks passed

⚠️ WARNINGS:
  - [SkillName]: Missing Examples section

❌ FAILED:
  - [SkillName]: Missing USE WHEN in description
```

### Step 4: Suggest Fixes

For each failure, provide:
1. What's wrong
2. The fix required
3. Example of correct format
