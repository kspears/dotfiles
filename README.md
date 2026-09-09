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

## AI profiles

AI configuration is split by the chezmoi `machine` value:

| Profile | Rules and skills |
|---|---|
| `work` | Shared rules plus ticket branches, MR preparation, Quanata infrastructure rules, and work integrations |
| `home` / `consulting` | Shared rules plus a lightweight GitHub-oriented workflow; work rules and org-specific skills are removed |

Shared Claude and Codex instructions are rendered from `.chezmoitemplates/ai/`.
Cursor keeps separate `.mdc` files because it supports scoped rules.

The AI Spellbook is the source of truth for work skills. Install or update its
global items only on a work profile:

```sh
spellbook sync --global
```

To switch an existing machine, change `machine` in
`~/.config/chezmoi/chezmoi.toml`, then run `chezmoi apply`. The profile cleanup
removes stale work-only rules and skills when leaving the work profile.

## Updating

```sh
chezmoi update
```
