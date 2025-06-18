function aws_rdp() { aws ec2-instance-connect open-tunnel --remote-port 3389  --local-port 13389 --instance-id "$@"}
function aws_ssh() { aws ec2-instance-connect ssh --instance-id "$@"}

alias k='kubectl'
alias d='dirs -v'

for index ({1..9}) alias "$index"="cd +${index}"; unset index
