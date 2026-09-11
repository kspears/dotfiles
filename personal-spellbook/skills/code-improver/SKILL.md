---
name: code-improver
description: Review recently written or modified code for readability, performance, best practices, and project convention issues. Use when the user asks for a code review, cleanup suggestions, implementation feedback, or a second opinion on code quality, especially for TypeScript, React, frontend modules, hooks, stores, or utility files.
---

# Code Improver

Read the target files before reviewing them.

Give a focused, actionable review that improves code quality without changing intended behavior.

## Review priorities

- Start with the highest-impact issues.
- Prefer readability, correctness, maintainability, and project convention issues over trivial style nits.
- Suggest the smallest viable fix.
- Do not invent work when the code is already solid.

## Project convention checks

If the repo has a `CLAUDE.md` or `AGENTS.md`, use it as the primary source of project-specific conventions.

## Review rules

- Do not suggest behavior-changing refactors unless the current behavior is clearly a bug.
- Do not add abstractions, wrappers, or helper functions unless they clearly solve a real issue.
- Do not suggest comments that only restate the code.
- Flag missing async error handling when it can cause broken UX or hidden failures.
- If there are no meaningful issues, say so directly.

## Output format

For each issue, use this structure:

### [Category]: [Short title]

**Why it matters**: [One sentence on the impact.]

**Current code**:
```[lang]
// small relevant snippet
```

**Improved version**:
```[lang]
// corrected snippet
```

Finish with a **Summary** section containing:
- total issues by category
- one sentence on overall code quality
- any repeated pattern worth watching
