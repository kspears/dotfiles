zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/.zcompcache"
zstyle ':completion:*:*:cp:*' file-sort size
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*'
zstyle ':completion:*' menu no
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'


# aws: offer the custom subcommands from aws.zsh, then defer to aws_completer.
_aws_with_custom() {
  local -a custom=(
    'switch:Switch AWS SSO profile'
    'login:Log in with aws-sso-util'
    'console:Open the console for $AWS_PROFILE'
    'local:Point the CLI at LocalStack'
  )
  (( CURRENT > 2 )) && (( ${custom[(I)${words[2]}:*]} )) && return

  (( CURRENT == 2 )) && _describe -t custom-commands 'custom command' custom

  local line="${(j: :)words[1,CURRENT]}"
  local -a matches=(${(f)"$(COMP_LINE=$line COMP_POINT=${#line} aws_completer 2>/dev/null)"})
  compadd -a matches
}
(( $+commands[aws_completer] )) && compdef _aws_with_custom aws

# fzf-tab must load after compinit and before widget-wrapping plugins.
FZF_TAB="/opt/homebrew/share/fzf-tab/fzf-tab.zsh"
if [[ -r "$FZF_TAB" ]]; then
  source "$FZF_TAB"
  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 $realpath'
fi
unset FZF_TAB
