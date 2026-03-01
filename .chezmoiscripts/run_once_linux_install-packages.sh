#!/bin/bash
set -e
if command -v apt-get &>/dev/null; then
  sudo apt-get update
  sudo apt-get install -y neovim tmux htop awscli git curl
elif command -v dnf &>/dev/null; then
  sudo dnf install -y neovim tmux htop awscli git curl
fi
