# Shared Skills

Pure-prompt skills that are portable across coding agents (no agent-specific tool calls in the body). Each skill lives in its own directory with a `SKILL.md` containing YAML frontmatter (`name`, `description`) and the prompt body.

## Current skills

- `code-improver/` — focused code review for readability, performance, convention adherence
- `security-reviewer/` — security audit of a recent change set

## Wiring

| Agent | Path | Type |
| --- | --- | --- |
| Codex CLI | `~/.codex/skills/<name>` | Symlink to `~/.agents/shared/skills/<name>` |
| Claude Code | not currently wired | Subagent format (`~/.claude/agents/<name>.md`) differs; port manually when content is genuinely agent-agnostic |

## Authoring rules

- No hard-coded references to a specific agent's tool names (`Read`, `Edit`, etc.). Speak about files generically.
- No hard-coded project context. If the repo has a `CLAUDE.md` or `AGENTS.md`, instruct the skill to read it for project conventions.
- Keep frontmatter minimal (`name`, `description`). Agent-specific frontmatter (model, color, tool allowlists) goes in the agent's native wrapper, not here.
