#!/bin/bash
# {{ include "dot_Brewfile.tmpl" | sha256sum }}
set -e
brew bundle check --global --no-upgrade || brew bundle install --global --no-upgrade
