---
name: ContextOptimizer
description: Optimizes CLAUDE.md, AGENTS.md, and other agent context files in a repository using research-backed principles. USE WHEN optimize context files OR audit CLAUDE.md OR improve agents.md OR reduce context bloat OR review agent instructions. Based on "Evaluating AGENTS.md" (Gloaguen et al., 2025) findings.
---

# ContextOptimizer

Analyzes and optimizes repository-level agent context files (CLAUDE.md, AGENTS.md, .cursorrules, etc.) using evidence-based principles from the paper "Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?" (Gloaguen et al., ICML 2025).

## Key Research Findings (Paper Reference)

The paper found that context files **tend to reduce task success rates** while **increasing inference cost by 20%+**. The core problem: unnecessary requirements make tasks harder. However, **developer-written minimal context files slightly outperform having no context at all**. The skill applies these findings to produce optimized, minimal context files.

## Workflow Routing

| Workflow | Trigger | File |
|----------|---------|------|
| **Audit** | "audit context files", "analyze CLAUDE.md" | `Workflows/Audit.md` |
| **Optimize** | "optimize context files", "improve CLAUDE.md" | `Workflows/Optimize.md` |
| **Generate** | "generate context file", "create CLAUDE.md from scratch" | `Workflows/Generate.md` |

## Examples

**Example 1: Audit existing context files**
```
User: "Audit the context files in this repo"
→ Invokes Audit workflow
→ Scans for CLAUDE.md, AGENTS.md, .cursorrules, .github/copilot-instructions.md
→ Scores each file against research-backed anti-patterns
→ Returns report with specific line-level recommendations
```

**Example 2: Optimize a bloated CLAUDE.md**
```
User: "Optimize my CLAUDE.md"
→ Invokes Optimize workflow
→ Reads current file, detects anti-patterns
→ Produces optimized version: removes redundancy, trims codebase overviews, keeps only actionable constraints
→ Shows before/after diff for user approval
```

**Example 3: Generate minimal context from scratch**
```
User: "Generate a CLAUDE.md for this repo"
→ Invokes Generate workflow
→ Explores repo structure, build system, test commands
→ Produces minimal context file with only non-obvious, actionable requirements
→ Avoids codebase overviews (paper found them ineffective)
```
