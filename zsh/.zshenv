export DOTFILES="$HOME/.dotfiles"
export XDG_CONFIG_HOME="$HOME/.config"
#export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file


alias assume=". assume"

fpath=(/Users/kevinspears/.granted/zsh_autocomplete/assume/ $fpath)

fpath=(/Users/kevinspears/.granted/zsh_autocomplete/granted/ $fpath)