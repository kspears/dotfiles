autoload -Uz add-zsh-hook
setopt PROMPT_SUBST

# Ayu Dark
_c_gray="#626a73"
_c_blue="#39bae6"
_c_green="#91b362"
_c_yellow="#e6b450"
_c_cyan="#95e6cb"
_c_red="#f07178"

# ---- Git ----
_git_info() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
  local dirty=""
  [[ -n $(git status --porcelain 2>/dev/null) ]] && dirty="*"
  print -n " %F{$_c_green}($branch$dirty)%f"
}

# ---- AWS profile (only when set) ----
_aws_info() {
  [[ -n "$AWS_PROFILE" ]] || return
  print -n " %F{$_c_yellow}aws:$AWS_PROFILE%f"
}

# ---- k8s context (only when set) ----
_k8s_info() {
  local kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
  [[ -f "$kubeconfig" ]] || return
  local ctx
  ctx=$(grep "^current-context:" "$kubeconfig" 2>/dev/null | awk '{print $2}')
  [[ -n "$ctx" && "$ctx" != "null" ]] && print -n " %F{$_c_cyan}⎈ $ctx%f"
}

# ---- Command duration ----
_cmd_start=0
_cmd_duration=""

_preexec() {
  _cmd_start=$SECONDS
}

_precmd() {
  if (( _cmd_start > 0 )); then
    local elapsed=$(( SECONDS - _cmd_start ))
    (( elapsed >= 1 )) && _cmd_duration=" %F{$_c_gray}${elapsed}s%f" || _cmd_duration=""
  else
    _cmd_duration=""
  fi
  _cmd_start=0
}

add-zsh-hook preexec _preexec
add-zsh-hook precmd _precmd

# ---- Prompt ----
# [14:23] ~/code/dotfiles (master*) aws:prod ⎈ my-cluster 3s
# ❯
PROMPT='%F{$_c_gray}[%D{%H:%M}]%f %F{$_c_blue}%~%f$(_git_info)$(_aws_info)$(_k8s_info)${_cmd_duration}
%(?.%F{$_c_green}.%F{$_c_red})❯%f '
