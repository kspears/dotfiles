#!/bin/bash
# Remove broken symlinks left behind by old install.sh
for f in "$HOME/.vimrc" "$HOME/prompt" "$HOME/aliases_pf.zsh" "$HOME/.config/starship.toml"; do
  [ -L "$f" ] && rm "$f" || true
done
