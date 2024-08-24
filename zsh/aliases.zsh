alias k='kubectl'
alias granted-sso-populate='granted sso populate --sso-region us-east-2 https://prisonfellowship.awsapps.com/start'
alias granted-sso-login='granted sso login --sso-region us-east-2 --sso-start-url https://prisonfellowship.awsapps.com/start'
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index
