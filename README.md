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

On home and consulting machines, `.zshrc` sets `SPELLBOOK_DIR` to the personal
catalog in the chezmoi source directory. `chezmoi update` updates that catalog
along with the rest of the dotfiles.

Install the selected catalog for all three agents:

```sh
spellbook init --global --target cursor,claude,codex
```

Update the catalog and installed skills on a work machine:

```sh
spellbook update
spellbook sync --global --target cursor,claude,codex
```

On a home or consulting machine, update dotfiles first, then synchronize from
its selected local catalog:

```sh
chezmoi update
spellbook sync --global --target cursor,claude,codex
```

On home and consulting machines, `SPELLBOOK_DIR` takes precedence and
Spellbook reads the catalog directly from dotfiles.

Chezmoi does not install, remove, migrate, or reconcile live skill directories.
Changing `machine` changes the behavioral instructions only; it is not a skill
catalog migration workflow.

## Updating

```sh
chezmoi update
```
