# CanonicalizeSkill Workflow

> **Trigger:** "canonicalize skill", "fix skill structure"

## Purpose

Brings an existing skill into compliance with SkillSystem.md standards.

## Steps

### Step 1: Identify Skill

Ask user which skill to canonicalize.

### Step 2: Backup Current State

```bash
cp -r $PAI_DIR/skills/[skill] $PAI_DIR/skills/[skill].backup
```

### Step 3: Fix Directory Naming

If directory is not TitleCase:

```bash
# Rename to TitleCase
mv $PAI_DIR/skills/old-name $PAI_DIR/skills/NewName
```

### Step 4: Fix File Naming

Rename workflow and tool files to TitleCase:

| Before | After |
|--------|-------|
| `workflows/create.md` | `Workflows/Create.md` |
| `tools/manage-server.ts` | `Tools/ManageServer.ts` |

### Step 5: Fix SKILL.md

#### Ensure Single-Line Description
```yaml
# Wrong (multi-line)
description: |
  This is a multi-line
  description

# Correct (single line)
description: Brief description. USE WHEN trigger1 OR trigger2.
```

#### Add USE WHEN Clause
```yaml
# Wrong
description: Manages server configuration.

# Correct
description: Manages server configuration. USE WHEN server config OR daemon management.
```

#### Add Missing Sections
- Add `## Workflow Routing` table if missing
- Add `## Examples` section with 2-3 examples

### Step 6: Regenerate Index

```bash
bun run $PAI_DIR/Tools/GenerateSkillIndex.ts
```

### Step 7: Verify

```bash
bun run $PAI_DIR/Tools/SkillSearch.ts [skill-name]
```

## Report Format

```
📋 SUMMARY: Canonicalized [SkillName] skill

⚡ ACTIONS:
  - Renamed directory: old-name → NewName
  - Renamed files to TitleCase
  - Added USE WHEN clause to description
  - Added Examples section

✅ RESULTS: Skill now conforms to SkillSystem.md standards
```
