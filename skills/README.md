# Skills

Portable, prompt-only skills for this machine, symlinked into `~/.claude/skills/`
and `~/.codex/skills/` by chezmoi. This directory is source-only — `.chezmoiignore`
keeps it from being copied into the home directory, and the symlinks point back
here so `chezmoi update` updates the skills along with everything else.

Work skills live in the company AI Spellbook repository and never land on this
machine. If a skill is useful in both places, keep an explicit copy in each.

## Adding a skill

1. Create `skills/<name>/SKILL.md` with minimal frontmatter (`name`, `description`),
   plus `agents/openai.yaml` with Codex's `display_name`, `short_description`, and
   `default_prompt` if Codex should see it too — copy an existing one.
2. Write the body without naming any specific agent's tools. Speak generically about
   reading files and running commands; an agent-specific hint is fine only when it is
   phrased conditionally and paired with a generic fallback.
3. Add `dot_claude/skills/symlink_<name>.tmpl` and `dot_codex/skills/symlink_<name>.tmpl`,
   each containing `{{ .chezmoi.sourceDir }}/skills/<name>`, then `chezmoi apply`.

Keep frontmatter minimal. Agent-specific frontmatter (model, color, tool allowlists)
belongs in that agent's own wrapper, not here.
