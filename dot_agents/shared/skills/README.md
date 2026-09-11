# Shared Skills

Pure-prompt skills that are portable across coding agents (no agent-specific tool calls in the body). Each skill lives in its own directory with a `SKILL.md` containing YAML frontmatter (`name`, `description`) and the prompt body.

## Current skills

- `code-improver/` — focused code review for readability, performance, convention adherence
- `security-reviewer/` — security audit of a recent change set
- `interview-to-spec/` — interview in rounds, then write `docs/specs/<slug>.md` an agent can build from

## Wiring

See "Adding a new shared skill" in the top-level `~/.agents/README.md`. Both agents discover skills through chezmoi-managed symlinks into this directory.

## Authoring rules

- No hard-coded references to a specific agent's tool names (`Read`, `Edit`, etc.). Speak about files generically. An agent-specific hint is allowed only when phrased conditionally ("in Claude Code, ...") and paired with a generic fallback.
- No hard-coded project context. If the repo has a `CLAUDE.md` or `AGENTS.md`, instruct the skill to read it for project conventions.
- Keep frontmatter minimal (`name`, `description`). Agent-specific frontmatter (model, color, tool allowlists) goes in the agent's native wrapper, not here.
