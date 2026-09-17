# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/).

## Setup

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply kevin
```

## What's included

- **zsh** — aliases, completion, prompt, plugins
- **neovim** — single-file config with lazy.nvim
- **tmux** — Ayu Dark theme
- **kitty** — terminal config
- **AI tools** — profile-aware Cursor, Claude Code, and Codex rules
- **Brewfile** — Homebrew dependencies (macOS)
- **AWS config** — templated per machine type

## Machine types

Chezmoi prompts for a machine type (`home`, `work`, `consulting`) on first init. Templates use this to conditionally include machine-specific config (e.g. Brewfile extras, zshrc paths).

## AI behavior profiles

Chezmoi selects a small instruction layer from the `machine` value:

| Profile | Behavior |
|---|---|
| `work` | Shared rules plus ticket branches, MR preparation, Quanata infrastructure rules, and work tooling guidance |
| `home` / `consulting` | Shared rules plus a lightweight GitHub-oriented workflow |

Shared Claude and Codex instructions are rendered from `.chezmoitemplates/ai/`.
Cursor keeps separate `.mdc` files because it supports scoped rules.

## AI skill catalogs

Home and work skills are separate catalogs, and nothing is shared between them.
If both environments need a skill, keep an explicit copy in each.

Home and consulting machines use `skills/` in this repository. Chezmoi symlinks
each skill into `~/.claude/skills/` and `~/.codex/skills/`, so `chezmoi apply` is
the whole install step and `chezmoi update` is the whole update step. Adding a
skill means adding its directory plus a `symlink_<name>.tmpl` under
`dot_claude/skills/` and `dot_codex/skills/` — see `skills/README.md`.

Work machines use the company AI Spellbook repository, managed by its own
`spellbook` CLI and outside chezmoi entirely:

```sh
spellbook config set-repo https://gitlab.com/quanata/projects/ai/ai-spellbook
spellbook init --global --target cursor,claude,codex
spellbook update && spellbook sync --global --target cursor,claude,codex
```

`.chezmoiignore` wires up exactly one of the two per machine. Changing `machine`
changes which catalog is active; it does not migrate skills between them.

## Updating

```sh
chezmoi update
```
