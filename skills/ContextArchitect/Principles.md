# ContextArchitect — Research-Backed Principles

Compiled from Gloaguen et al. 2026, Anthropic official docs, OpenAI Codex docs, and community patterns (Feb 2026).

---

## 1. The Loading Hierarchies

### Claude Code

Claude Code loads context from multiple levels, all **additive** (more specific overrides on conflict):

| Priority | Location | Scope | Always Loaded? |
|----------|----------|-------|----------------|
| 1 (highest) | Managed policy | Org-wide | Yes |
| 2 | `~/.claude/CLAUDE.md` | All projects | Yes |
| 3 | `./CLAUDE.md` or `.claude/CLAUDE.md` | This repo | Yes |
| 4 | `.claude/rules/*.md` | This repo (path-filterable) | Yes |
| 5 | `CLAUDE.local.md` | Personal, this repo | Yes |
| 6 | Auto memory | Per-project notes | First 200 lines |

**Skills priority (name collisions):** Enterprise > Personal (`~/.claude/skills/`) > Project (`.claude/skills/`).

**Skills use progressive disclosure:** Only descriptions (~100 tokens each) load at startup. Full content loads on invocation. Supporting files load on reference.

**No native skill inheritance.** Closest workaround: symlinks in `.claude/rules/`.

### OpenAI Codex

Codex builds an instruction chain from AGENTS.md files:

| Priority | Location | Scope | Always Loaded? |
|----------|----------|-------|----------------|
| 1 (highest) | `~/.codex/AGENTS.override.md` | Temporary global override | Yes (if exists) |
| 2 | `~/.codex/AGENTS.md` | All projects (global) | Yes |
| 3 | `./AGENTS.md` (repo root) | This repo | Yes |
| 4 | Nested `AGENTS.md` files | Walking down to CWD | Yes |

**Key differences from Claude Code:**
- Codex uses `AGENTS.md` (not `CLAUDE.md`)
- Global location is `~/.codex/AGENTS.md` (not `~/.claude/CLAUDE.md`)
- No rules system — all instructions go in AGENTS.md files
- No skills system — Codex has its own skills format
- Size limit: combined files capped at `project_doc_max_bytes` (32 KiB default)
- Discovery is configurable via `project_doc_fallback_filenames` in `~/.codex/config.toml`
- Codex skips empty files

### Cross-Agent Pattern

For environments using both Claude Code and Codex, keep a single source of truth:

```
~/dotfiles/.claude/CLAUDE.md  --stow-->  ~/.claude/CLAUDE.md   (Claude global)
~/dotfiles/.codex/AGENTS.md   --stow-->  ~/.codex/AGENTS.md    (Codex global)
```

Both files should carry the same working agreements (stack, standards, infra). Edit one, mirror to the other, or generate both from a shared source.

## 2. The Progressive Disclosure Stack

```
Layer 1 (Always loaded):     CLAUDE.md / AGENTS.md (~50 lines, ~500 tokens)
Layer 2 (Always loaded):     .claude/rules/*.md (path-filtered when possible)
Layer 3 (Description only):  Skill frontmatter (~100 tokens per skill)
Layer 4 (On invocation):     Skill body content
Layer 5 (On reference):      Skill supporting files (reference docs, scripts)
Layer 6 (On demand):         /docs, code comments (read by agent when relevant)
```

Only Layers 1-3 consume tokens every session. Everything else is on-demand.

Note: Codex has no equivalent of Layers 2-3 (rules, skills). All Codex context is always-loaded AGENTS.md content.

## 3. The Gloaguen Paper (2026) — Key Findings

**Source:** "Evaluating AGENTS.md" — Gloaguen et al., arXiv:2602.11988, ETH Zurich.

### What hurt performance
- LLM-generated context files **reduced** success rates ~3%, increased cost 20%+
- Repository overviews and directory descriptions provided **zero navigation benefit**
- Excessive guidance created cognitive burden — agents spent 14-22% more reasoning tokens

### What helped
- **Tooling instructions** were reliably followed (mentioned tools used 2.5x more)
- **Human-written minimal constraints** improved performance ~4%
- When documentation was removed from repos, LLM-generated context compensated (+2.7%)

### Recommendations
- "Describe only minimal requirements"
- Omit structural overviews — agents discover files independently
- Focus on what is **unique and non-obvious** about the codebase
- Prefer deterministic enforcement (hooks, linters) over prose instructions

## 4. The Placement Decision Framework

```
Is it always true for ALL projects?      -> ~/.claude/CLAUDE.md + ~/.codex/AGENTS.md
Is it always true for THIS project?      -> ./CLAUDE.md + ./AGENTS.md (or .claude/rules/*.md)
Is it a repeatable workflow?             -> Skill
  Used across all projects?              -> ~/.claude/skills/
  Used in this project only?             -> .claude/skills/
Is it enforceable by a tool?             -> Hook or linter (NOT prose)
Can the agent figure it out from code?   -> Don't write it at all
```

**Litmus test:** "Would I want this instruction active even when I'm not thinking about it?"
- Yes -> Rule or CLAUDE.md/AGENTS.md (always loaded)
- No -> Skill (loaded on demand)

## 5. The Layering Pattern (Avoiding Duplication)

### Layer 1: User-Level Skill (generic logic)
`~/.claude/skills/DevFlow/` — Universal pipeline stages, guardrails, output format.
**No project-specific details.** Works in any git repo.

### Layer 2: Project CLAUDE.md / AGENTS.md (project constants)
Declares specifics the generic skill can't know:
```markdown
## DevFlow Config
- Main branch: master
- Prod hosts: your-prod-server
- Linter: uv run ruff check . && uv run black --check .
- Review bot: CodeRabbit
```

### Layer 3: Project-Level Skill Override (rare)
Only when the project needs **different workflow logic**, not just different config values.
Most projects should NOT need this layer.

### Anti-Pattern: Duplicating logic at both levels
If the user-level skill handles 90% and the project override repeats that 90% plus adds 10%, you've duplicated 90%. Instead, put the 10% in `.claude/rules/` or project CLAUDE.md.

## 6. Content Placement Rules

### What belongs in global context (~50 lines max)
- Stack defaults, code standards, git workflow
- Machine topology and infrastructure summary
- Cross-project gotchas

### What belongs in project context (~50-100 lines)
- Build/test/lint commands the agent can't guess
- Code style rules that differ from language defaults
- Repo-specific gotchas
- Architecture constraints ("SQLite not Postgres because X")

### What belongs in .claude/rules/ (path-filtered, Claude only)
- Deep domain knowledge for specific directories
- Framework-specific constraints (e.g., "templates must pass X vars")
- Security rules for specific file patterns

### What belongs in user-level skills (Claude only)
- Generic workflows used across projects (DevFlow, CodeReview, BlogWriter)
- Personal productivity patterns
- Tool orchestration (browser automation, deployment)

### What belongs in project-level skills
- Project-specific workflows that have different **logic** (not just config)
- Workflows that reference project-specific files or APIs

### What belongs NOWHERE (remove it)
- Directory structure overviews (agents discover independently)
- General coding patterns (agents infer from existing code)
- Anything already in README or CONTRIBUTING.md
- Rules that a linter/hook already enforces

## 7. Sizing Guidelines

| Component | Target Size | Ceiling |
|-----------|------------|---------|
| `~/.claude/CLAUDE.md` | ~30 lines | 50 lines |
| `~/.codex/AGENTS.md` | ~30 lines | 50 lines |
| Project `CLAUDE.md` | ~50 lines | 100 lines |
| Project `AGENTS.md` | ~50 lines | 100 lines |
| Each `.claude/rules/*.md` | ~20 lines | 50 lines |
| Skill `SKILL.md` body | ~50 lines | 500 lines |
| Skill description (frontmatter) | 1 line | 1024 chars |
| Total always-loaded (Claude) | ~500 tokens | ~1000 tokens |
| Total always-loaded (Codex) | ~500 tokens | 32 KiB combined |

**Practical instruction ceiling:** ~100-150 custom instructions. System prompt uses ~50, leaving ~100 for your rules. Beyond that, adherence drops.

**Skill description budget:** 2% of context window (fallback: 16,000 chars). Too many skills = some excluded from discovery.

## 8. Quality Signals

### Signs of a well-organized setup
- CLAUDE.md and AGENTS.md each fit on one screen
- Global files (Claude + Codex) carry the same working agreements
- Rules use `paths:` frontmatter where possible
- User-level skills have zero project-specific references
- Project skills only exist when workflow logic genuinely differs
- No content duplicated between CLAUDE.md and skills
- Hooks/linters enforce what prose cannot guarantee

### Signs of a bloated setup
- CLAUDE.md or AGENTS.md > 100 lines
- Directory overviews or file-by-file descriptions present
- Same instructions repeated at user and project level
- Claude and Codex global files have drifted out of sync
- Rules that restate what linters already check
- Skills that are always invoked (should be rules instead)
- Generic coding advice agents already know

## 9. Positive Framing

LLMs amplify mentioned concepts. Positive framing outperforms negative:

| Avoid | Prefer |
|-------|--------|
| "Never use innerHTML" | "Use DOMPurify for sanitization" |
| "Don't use npm" | "Use bun for package management" |
| "Never commit to master" | "Always use feature branches" |

## 10. Sources

- [Gloaguen et al. 2026 — arXiv:2602.11988](https://arxiv.org/abs/2602.11988)
- [Extend Claude with skills](https://code.claude.com/docs/en/skills)
- [Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Manage Claude's memory](https://code.claude.com/docs/en/memory)
- [OpenAI Codex — Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md/)
- [OpenAI Codex — Agent Skills](https://developers.openai.com/codex/skills/)
- [AGENTS.md spec](https://agents.md/)
- [Stop Bloating Your CLAUDE.md](https://alexop.dev/posts/stop-bloating-your-claude-md-progressive-disclosure-ai-coding-tools/)
- [Miessler — Skills vs Workflows vs Agents](https://danielmiessler.com/blog/when-to-use-skills-vs-commands-vs-agents)
- [Agent Skills vs Rules vs Commands](https://www.builder.io/blog/agent-skills-rules-commands)
- [Claude Agent Skills: First Principles Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/)
- [Inside Claude Code Skills](https://mikhail.io/2025/10/claude-code-skills/)
- [Agent READMEs: Empirical Study — arXiv:2511.12884](https://arxiv.org/html/2511.12884v1)
