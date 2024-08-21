#!/bin/bash
# Kevin Spears
# 2023-04-16 : initial
# 2023-06-28 : making bash 3 compatiable
# 2024-08-21 : Removing oh-my-zsh

config_files=(
  '.tmux.conf|tmux/tmux.conf'
  '.zshrc|zshrc/zshrc'
  '.aws|aws/'
  '.git|git/'
  '.vimrc|vimrc/vimrc'
)

for item in "${config_files[@]}"; do
  dest=$(echo "${item}" | awk -F "|" '{print $1}')
  source=$(echo "${item}" | awk -F "|" '{print $2}')
  echo "Installing $source"
  ln -fs $PWD/${source} ~/${dest}
done
