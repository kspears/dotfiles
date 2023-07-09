#!/bin/bash
# mac install and updater
# 6/28/23

if [ ! -f "/opt/homebrew/bin/brew" ]; then 
    echo "install homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/kevin/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"

fi
brew_base=(
    '1password'
    'iterm2'
    'visual-studio-code'
    '1password-cli'
    'brave-browser'
    'firefox'
    'logi-options-plus'
    'signal'
    'htop'
)

brew_cloud_dev=(
    'awscli'
    'ansible'
    'nomad'
    'terraform'
    'node'
)

brew_media_convert=(
    'makemkv'
    'handbrake'
)

#create install args

brew_string=""
for item in "${brew_base[@]}"
do
    brew_string="$brew_string $item"
done

for item in "${brew_cloud_dev[@]}"
do
    brew_string="$brew_string $item"
done

for item in "${brew_media_convert[@]}"
do
    brew_string="$brew_string $item"
done

brew install ${brew_string}
