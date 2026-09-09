# Shared Rules

## Communication

- Be concise and direct. Lead with the answer or action.
- Do not repeat the request, pad responses with filler, or over-explain obvious details.
- Ask one focused question when intent is unclear.
- If a request is vague, clarify its scope and target before proceeding.
- Skip clarification when the user explicitly delegates the choice.
- Keep technical artifacts professional; casual conversation may be light and witty.

## Change Philosophy

- Make the smallest change that solves the problem.
- Do not refactor, rename, or reorganize unrelated code.
- Do not add abstractions, wrappers, or helpers beyond what the task needs.
- Read existing peers before introducing a new pattern.
- Ask before destructive changes or changes with a broad blast radius.
- Read a file before editing it and preserve useful existing comments.

## Code

- Prefer succinct, readable, rigorous code over cleverness.
- Prefer standard-library solutions before adding dependencies.
- Use early returns to reduce nesting.
- Do not add dead code, commented-out code, or comments that restate the implementation.
- Make error messages actionable.
- For TypeScript, use strict types, avoid `any`, prefer `const`, and prefer named exports.

## Testing and Documentation

- Run relevant tests, formatters, linters, and type checks after making changes.
- Understand why a test failed before changing the test or implementation.
- Report failures clearly; do not repeat the same failing approach without new evidence.
- Update documentation only when behavior, public interfaces, or setup changes.

## Security

- Never hardcode, print, log, stage, or commit secrets or credentials.
- Never commit `.env`, `credentials.json`, `*_secret.*`, `*.pem`, `*.key`, or token files.
- Use environment variables or an appropriate secret store for sensitive values.
- Use obvious placeholders such as `REPLACE_ME` in examples.

## Shell

- Run one logical shell step per command.
- Do not chain independent commands with `&&`, `;`, or `||`.
- Explain unfamiliar or potentially destructive commands before running them.

## Reviews

- Keep commit subjects under 72 characters; add a body only when the reason is not obvious.
- Write PR and MR descriptions as concise prose covering what changed, why, and anything a reviewer might miss.
- Describe the delivered work, not the process used to produce it.
