#!/bin/bash
#install .dotfiles
echo "creating symlinks for dotfiles"
ln -rfs ./tmux/tmux.conf ~/.tmux.conf
ln -rfs ./git/gitconfig ~/.gitconfig