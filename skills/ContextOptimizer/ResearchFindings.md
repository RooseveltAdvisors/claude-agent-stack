# Research Findings Reference

Source: "Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?"
Authors: Gloaguen, Mündler, Müller, Raychev, Vechev (ETH Zurich / SRI Lab)
Venue: ICML 2025
Paper: https://arxiv.org/abs/2602.11988

## Key Quantitative Results

### Performance Impact
- **LLM-generated context files**: Reduced success rate by ~3% on average across agents
- **Developer-written context files**: Marginal improvement of ~4% on average
- **Cost increase**: 20-23% more inference cost with context files present
- **Step increase**: 4-6 additional steps per task on average

### Tested Agents & Models
- Claude Code + Sonnet 4.5
- Codex + GPT-5.2 / GPT-5.1 mini
- Qwen Code + Qwen3-30b-coder

### Behavioral Effects
- Context files cause agents to run **more tests**, **grep more files**, **read more files**, **write more files**
- Agents **follow instructions in context files** (e.g., `uv` used 1.6x/instance when mentioned vs <0.01x when not)
- GPT-5.2 reasoning tokens increased 22% with LLM-generated context files
- Context files are **redundant with existing documentation** — when docs are removed, context files become helpful

## Anti-Patterns Identified

### 1. Codebase Overviews (INEFFECTIVE)
- 8/12 developer files included overviews; 90%+ of LLM-generated files did
- Did NOT help agents find relevant files faster
- Agents discover files through exploration just as efficiently without overviews

### 2. Redundant Documentation
- LLM-generated files are highly redundant with existing README, docs/, etc.
- Only become helpful when all other documentation is removed
- Token budget wasted on duplicated information

### 3. Excessive Requirements
- Additional instructions make tasks objectively harder (measured by reasoning tokens)
- Agents spend cycles on compliance instead of problem-solving
- More instructions → more steps → more cost → not better outcomes

### 4. Boilerplate & Generic Content
- Content that could apply to any repository provides no signal
- Promotional or marketing language wastes tokens

## What Actually Works

### 1. Minimal, Non-Obvious Requirements
- Specific tooling that differs from defaults (e.g., "use uv not pip")
- Project-specific test commands that aren't discoverable
- Constraints that would cause silent failures if not known

### 2. Repository-Specific Tooling References
- When context files mention a specific tool, agents use it
- This is the mechanism by which context files help: surfacing non-standard tools

### 3. Developer-Written Over LLM-Generated
- Human judgment about what matters > automated comprehensive listing
- Stronger models don't generate better context files
- Different generation prompts don't significantly change outcomes

### 4. Actionable Over Descriptive
- Instructions the agent can act on > descriptions of architecture
- "Run tests with `pytest -x --tb=short`" > "The project uses pytest for testing"

## The Optimization Principle

> "Unnecessary requirements from context files make tasks harder, and human-written context files should describe only minimal requirements."

### Decision Framework: Include a line if and only if:
1. The information is **not discoverable** from the codebase itself (README, pyproject.toml, package.json, etc.)
2. The information is **actionable** — it tells the agent to DO something specific
3. Getting it wrong would cause **silent failure** (not a loud error the agent can debug)
4. It applies to **most tasks** in the repo (not just one specific workflow)
