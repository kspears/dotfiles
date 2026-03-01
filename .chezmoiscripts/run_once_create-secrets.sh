#!/bin/bash
# Ensure secrets.zsh exists (sourced by .zshrc, never tracked)
# Remove broken symlink from old install.sh if present
[ -L "$HOME/secrets.zsh" ] && rm "$HOME/secrets.zsh"
[ -f "$HOME/secrets.zsh" ] || touch "$HOME/secrets.zsh"
