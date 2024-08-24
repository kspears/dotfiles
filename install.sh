#!/bin/bash
# Kevin Spears
# 2023-04-16 : initial
# 2023-06-28 : making bash 3 compatiable
# 2024-08-21 : Removing oh-my-zsh, simplified install
#

# zsh config files
ln -fs $PWD/zsh/.zshrc ~/.zshrc
ln -fs $PWD/zsh/.zshenv ~/.zshenv
ln -fs $PWD/zsh/aliases.zsh ~/aliases.zsh
ln -fs $PWD/zsh/completion.zsh ~/completion.zsh
ln -fs $PWD/zsh/prompt ~/prompt

# nvim
ln -fs $PWD/nvim/nvim ~/.confg/nvim

# tmux
ln -fs $PWD/tmux/.tmux.conf ~/.tmux.conf
