function aws_rdp() { aws ec2-instance-connect open-tunnel --remote-port 3389  --local-port 13389 --instance-id "$@"}
function aws_ssh() { aws ec2-instance-connect ssh --instance-id "$@"}
function aws_console() {aws-sso-util console launch-from-config}
function aws() {
  if [[ "$1" == "switch" ]]; then
    export AWS_PROFILE=$(grep '\[profile' ~/.aws/config | awk '{print $2}' | tr -d ']' | fzf)
    echo "Switched to profile: $AWS_PROFILE"
  else
    command aws "$@"
  fi
}

alias k='kubectl'
alias d='dirs -v'

for index ({1..9}) alias "$index"="cd +${index}"; unset index
