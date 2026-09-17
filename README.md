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

Home and work skills are separate catalogs. A work machine installs only the
company AI Spellbook repository; a home or consulting machine installs only
the `personal-spellbook/` catalog in this dotfiles repository. If both
environments need a skill, maintain a copy in each catalog instead of
inheriting from or synchronizing the other catalog.

On work machines, configure AI Spellbook as the catalog:

```sh
spellbook config set-repo https://gitlab.com/quanata/projects/ai/ai-spellbook
```

Install the work catalog for all three agents:

```sh
spellbook init --global --target cursor,claude,codex
```

Update the catalog and installed skills on a work machine:

```sh
spellbook update
spellbook sync --global --target cursor,claude,codex
```

Home and consulting machines do not require Spellbook. Chezmoi symlinks each
skill in `personal-spellbook/skills/` into `~/.claude/skills/` and
`~/.codex/skills/`, so `chezmoi apply` is the whole install step and `chezmoi
update` is the whole update step. Adding a skill means adding its directory
plus a `symlink_<name>.tmpl` under `dot_claude/skills/` and `dot_codex/skills/`.

`.zshrc` also sets `SPELLBOOK_DIR` to the personal catalog on those machines, so
Spellbook reads from dotfiles rather than a separate checkout if it is installed
later.

Chezmoi does not migrate or reconcile skills between the two catalogs. Changing
`machine` changes which catalog is wired up; it does not move skills between
them.

## Updating

```sh
chezmoi update
```
