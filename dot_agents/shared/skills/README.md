# Shared Skills

Pure-prompt skills that are portable across coding agents (no agent-specific tool calls in the body). Each skill lives in its own directory with a `SKILL.md` containing YAML frontmatter (`name`, `description`) and the prompt body.

## Current skills

- `code-improver/` — focused code review for readability, performance, convention adherence
- `security-reviewer/` — security audit of a recent change set
- `interview-to-spec/` — interview in rounds, then write `docs/specs/<slug>.md` an agent can build from

## Wiring

| Agent | Path | Type |
| --- | --- | --- |
| Codex CLI | `~/.codex/skills/<name>` | Symlink to `~/.agents/shared/skills/<name>` |
| Claude Code | `~/.claude/skills/<name>` | Symlink to `~/.agents/shared/skills/<name>` (`interview-to-spec` only so far; `code-improver` and `security-reviewer` are not yet linked) |

## Authoring rules

- No hard-coded references to a specific agent's tool names (`Read`, `Edit`, etc.). Speak about files generically.
- No hard-coded project context. If the repo has a `CLAUDE.md` or `AGENTS.md`, instruct the skill to read it for project conventions.
- Keep frontmatter minimal (`name`, `description`). Agent-specific frontmatter (model, color, tool allowlists) goes in the agent's native wrapper, not here.

Symlinks are chezmoi-managed: `dot_claude/skills/symlink_<name>.tmpl` and `dot_codex/skills/symlink_<name>.tmpl` in the dotfiles repo, each containing the target path. The older Codex links for `code-improver` and `security-reviewer` were made by hand and are not tracked.
