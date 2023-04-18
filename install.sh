#!/bin/bash
# Kevin Spears
# 2023-04-16

# Array of dotfiles to install
declare -A dotfiles
dotfiles[.tmux.conf]=./tmux/tmux.conf
dotfiles[.gitconfig]=./git/gitconfig
dotfiles[.zshrc]=./zshrc/zshrc

#loop through files to install configs
for key in "${!dotfiles[@]}"; do
	echo "Installing ${dotfiles[$key]}"
	ln -rfs ${dotfiles[$key]} ~/$key
done

#if needed install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then 
	echo "Installing oh-my-zsh"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi


