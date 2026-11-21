# Work Profile

## Git Workflow

- Detect the repository's default branch; never assume `main` or `master`.
- Create a feature branch before editing unless already working on an existing MR or PR branch.
- Use `<TICKET-ID>-short-description` when a ticket exists; otherwise use descriptive kebab-case.
- Never amend a pushed commit, rebase shared history, or force-push.
- Merge the latest remote branch before pushing.
- Do not commit, push, create an MR or PR, or merge unless the user asks.
- Before pushing for review, run the repository's relevant quality checks and simplify review.
- Do not merge an MR or PR when asked only to create one.

## Work Tools

- Prefer the installed work skills for Jira, GitLab, AWS, incidents, and internal documentation.
- Use only skills from the company work catalog; do not install or synchronize the personal catalog.
- Treat the company AI Spellbook catalog as the source of truth for work skills.
- When a skill is needed in both catalogs, maintain an independent copy in each instead of using cross-catalog inheritance.

## Personal Memory

- ATLAS (`forge` MCP `memory_*` tools) is cluster-hosted and read both by the deployed ATLAS
  assistant and by any agent with the `forge` MCP server configured.
- Save to ATLAS only when the fact is about Kevin personally (preferences, family, personal
  context) *and* the deployed assistant would reference it. The exception is short-term
  operational state with `expires_at` — ATLAS is the only store with expiry.
- Default to agent-native memory or rules files. Promote to ATLAS deliberately, not reflexively:
  every entry is a runtime cost for the assistant, not just session context.
- Query ATLAS before answering about Kevin's preferences, family, or ongoing situations.
