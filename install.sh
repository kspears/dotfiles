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
ln -fs $PWD/zsh/aliases.zsh ~/aliases_pf.zsh
ln -fs $PWD/zsh/secrets.zsh ~/secrets.zsh
ln -fs $PWD/zsh/completion.zsh ~/completion.zsh
ln -fs $PWD/zsh/prompt ~/prompt

ln -fs $PWD/starship.toml ~/.config/starship.toml

# nvim
ln -fs $PWD/nvim/.config/nvim ~/.config/nvim
# tmux
ln -fs $PWD/tmux/.tmux.conf ~/.tmux.conf
