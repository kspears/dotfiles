# Home Profile

## Git Workflow

- Create a feature branch before editing; never commit directly to the default branch.
- Use `feat/short-description` or `fix/short-description` when the repository has no stricter convention.
- Never rewrite pushed history or force-push.
- Commit completed work on the branch automatically — do not ask for confirmation.
- After committing, stop and wait for the user to test manually.
- Once the user confirms the change is good, push and open a PR automatically — no extra prompting.
- Before opening any PR, run a simplification and code-quality pass over the changes and address
  the findings first (Claude Code: `/simplify` then `/code-review`). Never open the PR before that
  pass has run.
- When told to merge, run `gh pr merge <number> --squash --delete-branch` from the feature branch.
  That single command merges, switches local to the default branch, pulls, and deletes the local
  branch — do not chain `git checkout` / `git pull` / `git branch -D` after it, they will error.
- Never merge, tag, or release unless explicitly requested.
- When creating a new GitHub repository, push `main` before any feature branch so GitHub sets it
  as the default.
- When asked to check a CI pipeline, run `gh run` commands directly rather than asking first.

## Personal Tools

- Prefer GitHub terminology and tooling unless the repository indicates otherwise.
- Do not assume access to Quanata Jira, GitLab, AWS accounts, or internal documentation.
- Use only skills from the personal catalog; do not install or synchronize the work catalog.
- When a skill is needed in both catalogs, maintain an independent copy in each instead of using cross-catalog inheritance.
- Before building a new feature, app, or service with no spec in `docs/specs/`, suggest the
  `interview-to-spec` skill. Skip the suggestion when the user delegates the choice; if they
  decline, proceed normally.

## Personal Memory

- ATLAS (`forge` MCP `memory_*` tools) is cluster-hosted and read both by the deployed ATLAS
  assistant and by any agent with the `forge` MCP server configured.
- Save to ATLAS only when the fact is about Kevin personally (preferences, family, personal
  context) *and* the deployed assistant would reference it. The exception is short-term
  operational state with `expires_at` — ATLAS is the only store with expiry.
- Default to agent-native memory or rules files. Promote to ATLAS deliberately, not reflexively:
  every entry is a runtime cost for the assistant, not just session context.
- Query ATLAS before answering about Kevin's preferences, family, or ongoing situations.
