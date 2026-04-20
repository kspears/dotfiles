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

# ---- AWS profile + SSO token countdown (only when set) ----
_aws_sso_ttl() {
  local cache_dir="$HOME/.aws/sso/cache"
  [[ -d "$cache_dir" ]] || return 1

  # Single python invocation scans the whole cache dir and emits
  # "<expiresAt> <refresh|fixed>" for the newest SSO session token.
  local token_info
  token_info=$(python3 - "$cache_dir" 2>/dev/null <<'PY'
import glob, json, os, sys
newest_exp = ""
has_refresh = False
for f in glob.glob(os.path.join(sys.argv[1], "*.json")):
    try:
        d = json.load(open(f))
    except Exception:
        continue
    if "startUrl" not in d:
        continue
    exp = d.get("expiresAt", "")
    if exp and exp > newest_exp:
        newest_exp = exp
        has_refresh = "refreshToken" in d
if newest_exp:
    print(newest_exp, "refresh" if has_refresh else "fixed")
PY
)
  [[ -z "$token_info" ]] && return 1

  local exp="${token_info% *}"
  local token_type="${token_info##* }"

  # Tokens with a refreshToken auto-renew; the 1h expiresAt is just the access token TTL
  [[ "$token_type" == refresh ]] && return 0

  local epoch now remaining
  epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$exp" "+%s" 2>/dev/null) || return 1
  now=$(date -u "+%s")
  remaining=$(( epoch - now ))

  if (( remaining <= 0 )); then
    return 1
  elif (( remaining < 900 )); then
    print -n " %F{$_c_red}$(( remaining / 60 ))m%f"
  elif (( remaining < 3600 )); then
    print -n " %F{$_c_yellow}$(( remaining / 60 ))m%f"
  else
    print -n " %F{$_c_gray}$(( remaining / 3600 ))h$(( (remaining % 3600) / 60 ))m%f"
  fi
}

_aws_info() {
  [[ -n "$AWS_PROFILE" ]] || return
  local ttl
  ttl=$(_aws_sso_ttl) || return
  print -n " %F{$_c_yellow}aws:$AWS_PROFILE%f$ttl"
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
_kitty_title() {
  [[ -n "$KITTY_LISTEN_ON" ]] && kitty @ set-tab-title "$1 [$(basename $PWD)]" 2>/dev/null
}

_preexec() {
  _cmd_start=$SECONDS
  _kitty_title "${1%% *}"
}

_precmd() {
  if (( _cmd_start > 0 )); then
    local elapsed=$(( SECONDS - _cmd_start ))
    (( elapsed >= 1 )) && _cmd_duration=" %F{$_c_gray}${elapsed}s%f" || _cmd_duration=""
  else
    _cmd_duration=""
  fi
  _cmd_start=0
  _kitty_title zsh
}

add-zsh-hook preexec _preexec
add-zsh-hook precmd _precmd

# ---- Prompt ----
# [14:23] ~/code/dotfiles (master*) aws:prod 4h23m ⎈ my-cluster 3s
# ❯
PROMPT='%F{$_c_gray}[%D{%H:%M}]%f %F{$_c_blue}%~%f$(_git_info)$(_aws_info)$(_k8s_info)${_cmd_duration}
%(?.%F{$_c_green}.%F{$_c_red})❯%f '
