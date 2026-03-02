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
- **claude** — Claude Code settings
- **Brewfile** — Homebrew dependencies (macOS)
- **AWS config** — templated per machine type

## Machine types

Chezmoi prompts for a machine type (`home`, `work`, `consulting`) on first init. Templates use this to conditionally include machine-specific config (e.g. Brewfile extras, zshrc paths).

## Updating

```sh
chezmoi update
```
