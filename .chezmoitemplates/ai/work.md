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
- Treat the AI Spellbook as the source of truth for shared work skills and rules.
- Follow repository-local `AGENTS.md`, `CLAUDE.md`, and `.cursor/rules` when present.
