#!/bin/bash
# ~/.codex/config.toml stays machine-local (per-project trust levels, notify paths),
# so chezmoi does not manage it. It pointed model_instructions_file at
# ~/.agents/shared/rules.md, which no longer exists — repoint it at the rendered
# ~/.codex/AGENTS.md so Codex and Claude read the same profile.
set -e

config="$HOME/.codex/config.toml"
[ -f "$config" ] || exit 0
grep -q '^model_instructions_file.*\.agents' "$config" || exit 0

tmp=$(mktemp)
sed "s|^model_instructions_file *=.*|model_instructions_file = \"$HOME/.codex/AGENTS.md\"|" "$config" > "$tmp"
cat "$tmp" > "$config"
rm -f "$tmp"
