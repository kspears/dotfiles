alias k='kubectl'
alias d='dirs -v'

for index ({1..9}) alias "$index"="cd +${index}"; unset index

# tmux
alias tl='tmux list-sessions'
alias ta='tmux attach -t'
alias tk='tmux kill-session -t'
alias tn='tmux new-session -s'

# cursor
cursor-cli() {
  local skills=""
  local -a names=()
  for f in ~/.cursor/skills/*/SKILL.md(N); do
    skills+="$(cat "$f")"$'\n---\n'
    names+="${f:h:t}"
  done

  if (( ${#names} )); then
    printf '\e[2mLoaded %d skill(s): %s\e[0m\n' ${#names} "${(j:, :)names}"
  else
    printf '\e[2mNo skills found in ~/.cursor/skills/\e[0m\n'
  fi

  local summary="Skills loaded: ${(j:, :)names}."
  local detail=$'\n\n---\n\n'"$skills"
  if [[ -n "$*" ]]; then
    cursor agent "$summary"$'\n\n'"$*"$'\n'"$detail"
  else
    cursor agent "$summary Ask what I need. Don't list the skills.$detail"
  fi
}
