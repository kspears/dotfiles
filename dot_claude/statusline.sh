#!/bin/bash
input=$(cat)

# -- Shell prompt fields --
TIME=$(date +%H:%M)
CWD=$(echo "$input" | jq -r '.workspace.current_dir // ""')
# Abbreviate home directory as ~
HOME_ESC=$(printf '%s\n' "$HOME" | sed 's/[[\.*^$()+?{|]/\\&/g')
CWD_DISPLAY=$(echo "$CWD" | sed "s|^$HOME_ESC|~|")

# Git info (skip locks to avoid contention)
GIT_INFO=""
if branch=$(git -C "$CWD" symbolic-ref --short HEAD 2>/dev/null); then
  dirty=""
  [[ -n $(git -C "$CWD" status --porcelain 2>/dev/null) ]] && dirty="*"
  GIT_INFO=" ($branch$dirty)"
fi

# AWS profile
AWS_INFO=""
[[ -n "$AWS_PROFILE" ]] && AWS_INFO=" aws:$AWS_PROFILE"

# k8s context
K8S_INFO=""
kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
if [[ -f "$kubeconfig" ]]; then
  ctx=$(grep "^current-context:" "$kubeconfig" 2>/dev/null | awk '{print $2}')
  [[ -n "$ctx" && "$ctx" != "null" ]] && K8S_INFO=" ⎈ $ctx"
fi

# -- Claude fields --
MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

FILLED=$((PCT / 10))
EMPTY=$((10 - FILLED))
BAR=$(printf "%${FILLED}s" | tr ' ' '▓')$(printf "%${EMPTY}s" | tr ' ' '░')

printf '[%s] %s%s%s%s | [%s] %s %s%%\n' \
  "$TIME" "$CWD_DISPLAY" "$GIT_INFO" "$AWS_INFO" "$K8S_INFO" \
  "$MODEL" "$BAR" "$PCT"
