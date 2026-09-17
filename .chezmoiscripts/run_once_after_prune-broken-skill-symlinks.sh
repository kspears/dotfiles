#!/bin/bash
# The ~/.agents/ tree is removed by .chezmoiremove, so any skill symlink still pointing
# into it is now broken. On work machines ~/.claude/skills and ~/.codex/skills are
# chezmoi-ignored, so chezmoi cannot repoint or remove those links itself.
#
# Runs after the rest of the apply so the links it checks are already in their final state.
for dir in "$HOME/.claude/skills" "$HOME/.codex/skills"; do
  [ -d "$dir" ] || continue
  for link in "$dir"/*; do
    [ -L "$link" ] || continue
    [ -e "$link" ] || rm "$link"
  done
done
