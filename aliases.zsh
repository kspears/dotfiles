alias k='kubectl'
alias d='dirs -v'

for index ({1..9}) alias "$index"="cd +${index}"; unset index

# tmux
alias tl='tmux list-sessions'
alias ta='tmux attach -t'
alias tk='tmux kill-session -t'
alias tn='dev ~/Documents/notes notes'

