# Per-profile console region overrides (default: us-east-1)
typeset -gA AWS_CONSOLE_REGIONS=(
    # example-profile us-west-2
)
AWS_CONSOLE_DEFAULT_REGION="us-east-1"

# AWS CLI helper function
function aws() {
  if [[ "$1" == "switch" ]]; then
    # Clear LocalStack variables when switching to SSO profile
    unset AWS_ENDPOINT_URL AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
    aws-sso-switch
  elif [[ "$1" == "login" ]]; then
    aws-sso-util login
  elif [[ "$1" == "console" ]]; then
    local profile="${AWS_PROFILE:-}"
    local region="${AWS_CONSOLE_REGIONS[$profile]:-$AWS_CONSOLE_DEFAULT_REGION}"
    aws-sso-switch --console --region "$region" "$profile"
  elif [[ "$1" == "local" ]]; then
    export AWS_ENDPOINT_URL="http://localhost:4566"
    export AWS_ACCESS_KEY_ID="test"
    export AWS_SECRET_ACCESS_KEY="test"
    export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
    export AWS_PROFILE="localstack"
    echo "Switched to LocalStack (endpoint: $AWS_ENDPOINT_URL)"
  else
    command aws "$@"
  fi
}

# AWS SSO Switch wrapper - automatically sets AWS_PROFILE in current shell
function aws-sso-switch() {
  local output=$(command aws-sso-switch "$@" 2>&1)
  local exit_code=$?

  # If the output contains an export command, eval it to set AWS_PROFILE
  if echo "$output" | grep -q '^export AWS_PROFILE='; then
    eval "$(echo "$output" | grep '^export AWS_PROFILE=')"
    echo "$output" | grep -v '^export AWS_PROFILE=' >&2
  else
    echo "$output"
  fi

  return $exit_code
}

# Load current AWS profile on shell startup if one was previously set
if [[ -f "$HOME/.aws/sso/current-profile" ]]; then
  export AWS_PROFILE=$(cat "$HOME/.aws/sso/current-profile" | tr -d '\n')
fi

function aws_rdp() { aws ec2-instance-connect open-tunnel --remote-port 3389 --local-port 13389 --instance-id "$@"; }
function aws_ssh() { aws ec2-instance-connect ssh --instance-id "$@"; }
function aws_console() { aws-sso-util console launch-from-config; }
