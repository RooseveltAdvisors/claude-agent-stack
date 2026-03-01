# Audit Workflow

> **Trigger:** "audit setup", "optimize skills", "check my organization", "context budget"

Scans the full context setup across both Claude Code and OpenAI Codex at user and project levels. Identifies duplication, bloat, misplacement, and cross-agent drift.

## Steps

### Step 1: Gather All Context Sources

Scan in parallel:

```bash
# Claude Code — User-level always-loaded content
cat ~/.claude/CLAUDE.md 2>/dev/null | wc -l
ls ~/.claude/skills/*/SKILL.md 2>/dev/null
ls ~/.claude/rules/*.md 2>/dev/null

# Claude Code — Project-level always-loaded content
cat CLAUDE.md 2>/dev/null | wc -l
cat .claude/CLAUDE.md 2>/dev/null | wc -l
cat CLAUDE.local.md 2>/dev/null | wc -l
ls .claude/rules/*.md 2>/dev/null
ls .claude/skills/*/SKILL.md 2>/dev/null

# OpenAI Codex — User-level always-loaded content
cat ~/.codex/AGENTS.md 2>/dev/null | wc -l
cat ~/.codex/AGENTS.override.md 2>/dev/null | wc -l

# OpenAI Codex — Project-level always-loaded content
cat AGENTS.md 2>/dev/null | wc -l

# Auto memory (Claude only)
cat ~/.claude/projects/*/memory/MEMORY.md 2>/dev/null | wc -l
```

### Step 2: Measure Always-Loaded Token Cost

Estimate tokens for everything loaded at session start:

**Claude Code:**
1. **CLAUDE.md files** (all levels) — count lines, estimate ~1.3 tokens/word
2. **Rules files** (all `.claude/rules/*.md`) — count lines
3. **Skill descriptions** — extract frontmatter `description:` from every SKILL.md (~100 tokens each)
4. **Auto memory** — first 200 lines of MEMORY.md

**OpenAI Codex:**
1. **AGENTS.md files** (global + project + nested) — count lines and bytes
2. Check against `project_doc_max_bytes` (32 KiB default)

**Targets:**
- Claude: Total always-loaded content < 1000 tokens. Flag if over.
- Codex: Total AGENTS.md chain < 32 KiB. Flag if over.

### Step 3: Check for Anti-Patterns

Read each file and check against `Principles.md` section 8 ("Quality Signals"):

| Anti-Pattern | Detection | Severity |
|---|---|---|
| **CLAUDE.md or AGENTS.md > 100 lines** | Line count | High |
| **Directory overviews** | Grep for "directory structure", "file tree", "project layout" | High |
| **Duplicated content** | Same instructions in CLAUDE.md AND a skill | High |
| **Cross-agent drift** | Diff ~/.claude/CLAUDE.md vs ~/.codex/AGENTS.md | High |
| **Same skill at both levels** | User skill name matches project skill name | Medium |
| **Generic coding advice** | Grep for "use descriptive names", "write tests", "handle errors" | Medium |
| **Linter rules in prose** | Instructions that ruff/eslint/prettier already enforce | Medium |
| **Negative framing** | "Never X", "Don't X" without positive alternative | Low |
| **Missing path filter** | Rules file without `paths:` frontmatter that only applies to specific dirs | Low |

### Step 4: Check Cross-Agent Consistency

Compare global context files for drift:

```bash
# Semantic diff between Claude and Codex global files
diff <(grep -v '^#' ~/.claude/CLAUDE.md | grep -v '^$') \
     <(grep -v '^#' ~/.codex/AGENTS.md | grep -v '^$')
```

Flag sections present in one but not the other. Both agents should share the same working agreements (stack defaults, code standards, infrastructure).

If managed via stow, verify symlinks:
```bash
ls -la ~/.claude/CLAUDE.md ~/.codex/AGENTS.md
# Should point to dotfiles/.claude/CLAUDE.md and dotfiles/.codex/AGENTS.md
```

### Step 5: Check Skill Organization

For each skill found at user level (`~/.claude/skills/`):
- Does it contain ANY project-specific references? (paths, hostnames, repo names) -> Flag as misplaced
- Is it duplicated at project level? -> Recommend removing project copy or making it a thin config override

For each skill found at project level (`.claude/skills/`):
- Is the logic generic enough for user level? -> Recommend promotion
- Does it duplicate a user-level skill's logic? -> Recommend removal, put project specifics in CLAUDE.md or rules

### Step 6: Generate Report

Output format:

```markdown
## ContextArchitect Audit Report

### Token Budget
| Source | Lines | Est. Tokens | Target |
|--------|-------|-------------|--------|
| ~/.claude/CLAUDE.md | N | N | <50 lines |
| ~/.codex/AGENTS.md | N | N | <50 lines |
| ./CLAUDE.md | N | N | <100 lines |
| ./AGENTS.md | N | N | <100 lines |
| .claude/rules/ (N files) | N | N | path-filtered |
| Skill descriptions (N skills) | -- | N | <100/skill |
| **Total always-loaded (Claude)** | **N** | **N** | **<1000 tokens** |
| **Total always-loaded (Codex)** | **N** | **N** | **<32 KiB** |

### Cross-Agent Consistency
- [OK/DRIFT] Global files in sync: ~/.claude/CLAUDE.md vs ~/.codex/AGENTS.md
- [OK/DRIFT] Project files in sync: ./CLAUDE.md vs ./AGENTS.md
- Stow-managed: [YES/NO]

### Issues Found
1. [SEVERITY] Description -- file:line -> Recommendation
2. ...

### Recommended Actions
- [ ] Move X from CLAUDE.md to .claude/rules/x.md with paths: filter
- [ ] Sync drifted section from CLAUDE.md to AGENTS.md (or vice versa)
- [ ] Promote .claude/skills/X to ~/.claude/skills/X (generic logic)
- [ ] Remove directory overview from CLAUDE.md (zero benefit per Gloaguen 2026)
- [ ] Merge duplicate content between X and Y
- ...
```

### Step 7: Offer to Execute

Ask the user if they want to execute any of the recommended file moves/edits.
