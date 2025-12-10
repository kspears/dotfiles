function aws_rdp() { aws ec2-instance-connect open-tunnel --remote-port 3389  --local-port 13389 --instance-id "$@"}
function aws_ssh() { aws ec2-instance-connect ssh --instance-id "$@"}
function aws_console() {aws-sso-util console launch-from-config}
function aws() {
  if [[ "$1" == "switch" ]]; then
    local profile=$(grep '\[profile' ~/.aws/config | awk '{print $2}' | tr -d ']' | fzf)
    if [[ -n "$profile" ]]; then
      export AWS_PROFILE="$profile"
      echo "Switched to profile: $AWS_PROFILE"
    else
      echo "No profile selected"
    fi
  elif [[ "$1" == "login" ]]; then
    aws-sso-util login
  else
    command aws "$@"
  fi
}

alias k='kubectl'
alias d='dirs -v'

for index ({1..9}) alias "$index"="cd +${index}"; unset index
