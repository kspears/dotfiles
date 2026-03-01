#!/bin/bash
# Ensure secrets.zsh exists (sourced by .zshrc, never tracked)
[ -f "$HOME/secrets.zsh" ] || touch "$HOME/secrets.zsh"
