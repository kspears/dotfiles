zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/.zcompcache"
zstyle ':completion:*:*:cp:*' file-sort size
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*'
zstyle ':completion:*' menu no
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'


#complete -C '/opt/homebrew/bin/aws_completer' aws

# fzf-tab must load after compinit and before widget-wrapping plugins.
FZF_TAB="/opt/homebrew/share/fzf-tab/fzf-tab.zsh"
if [[ -r "$FZF_TAB" ]]; then
  source "$FZF_TAB"
  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 $realpath'
fi
unset FZF_TAB
