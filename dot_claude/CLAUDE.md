# Global Claude Rules

## Communication Style
- Be concise. Don't repeat back what I said.
- Don't over-explain obvious things.
- Don't apologize or use filler phrases like "Great question!" or "Certainly!".
- When showing code changes, show only what changed with minimal surrounding context.
- When unsure about intent, ask a short clarifying question rather than guessing.
- If a request is vague — multiple valid interpretations exist, scope is unclear, or the target isn't specified — interview me before proceeding. Ask all clarifying questions in a single structured message (numbered list). Do not guess or proceed with assumptions.
- Skip the interview if the request includes a signal like "surprise me", "your call", or "just do something".

## Change Philosophy
- Make the smallest change that solves the problem.
- Don't refactor, rename, or "improve" surrounding code unless asked.
- Don't add abstractions, wrappers, or helper functions beyond what was requested.
- If a task requires a large change, explain the approach first and wait for approval.
- Follow existing patterns in the codebase — don't introduce new conventions without discussion.

## Code Preferences
- TypeScript: strict types, no `any`, prefer `interface` for object shapes.
- Use early returns to reduce nesting.
- Prefer `const` over `let` where possible.
- Prefer named exports over default exports.
- Don't add comments that just restate what the code does.
- Use existing patterns in the codebase as the guide for new code.

## Git
- Never use `git -C` — the working directory is already set correctly, use `git` directly.
- Always create a branch before starting work — never commit directly to main.
- Name branches `fix/short-description` or `feat/short-description` based on the type of change.
- Commit completed work automatically on the branch — do not ask for confirmation.
- Stage files and push the branch to remote automatically — do not ask for confirmation.
- When work is complete, open a PR from the branch into main — do not ask for confirmation.
- Never push to main without explicit approval.
- Never create or push tags or release commits without explicit approval.
- Never commit `.env` files, API keys, tokens, or credentials.
- Never add Co-Authored-By lines to commit messages.
- When told to merge a PR, use `gh pr merge <number> --squash --delete-branch` and then checkout main and pull.
- Always `sleep 0.1` between `git add` and `git commit` to avoid index.lock race with background git status polling.

## Testing
- Run existing tests after making code changes.
- For TypeScript changes, run `tsc --noEmit` before committing — especially after refactors that affect multiple consumers.
- Run linter on modified files and fix any errors you introduced.
- Report failures clearly; don't retry the same failing approach.
- Look at tests skeptically — test desired functionality, not just validate the code that was written.
- If you find yourself repeating a task more than once with low confidence, stop and ask for help.

## Documentation
- Only update docs when a change affects user-facing behavior, a public API/exported interface, or setup/installation steps.
- Don't add or update docs just because code changed internally.

## Safety Guardrails
- Always read a file before editing it.
- Never delete files without asking for confirmation first.
- Never run destructive commands (`rm -rf`, `DROP TABLE`, `git push --force`) without explicit approval.
- Don't overwrite user data or database files without confirmation.
- When running unfamiliar shell commands, explain what they do before executing.

## Package Management (macOS)
- Prefer `brew install` over `pip`, `pip3`, `gem`, or other system-level installers.
- Only fall back to language-specific installers (pip, cargo install, npm -g) when the package isn't available in Homebrew.
