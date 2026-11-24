alias k='kubectl'
alias d='dirs -v'
(( $+commands[podman] && ! $+commands[docker] )) && alias docker='podman'

for index ({1..9}) alias "$index"="cd +${index}"; unset index

alias tn='dev ~/Documents/notes notes'

