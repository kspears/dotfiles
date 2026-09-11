# Claude Code Overlay

Claude-specific rules that sit on top of `~/.agents/shared/rules.md`. The shared file is loaded first via `@`-import; this overlay extends or overrides where the harness has unique features.

## Model & Agent Strategy
- Keep Opus for planning, investigation, architecture decisions, and review.
- Spawn Sonnet subagents for implementation work: file edits, builds, tests, repetitive tasks.
- Use your judgment on agent model selection — use Sonnet by default for subagents, Opus only when the subtask genuinely needs deeper reasoning, Haiku for trivial lookups.
- When a task is purely mechanical (apply a pattern across files, run a build, grep for something), don't burn Opus tokens on it — delegate.

## Workflow (Claude-specific)
- Use `run_in_background` for slow commands (test suites, builds) so the loop doesn't stall.

## Plans
- When the user says to "start work on a plan" (or equivalent), run `/compact` first before beginning implementation.
- Plans are saved to `~/.claude/plans/` with random filenames.
- If a spec for the feature exists in `docs/specs/` (written by the `interview-to-spec` skill), read it before drafting the plan and treat its acceptance criteria as the plan's definition of done.
- Whenever a plan is created or completed, log it in the project's `MEMORY.md` under a **Saved Plans** table with the filename, feature name, and status (`Ready to implement` / `In progress` / `Done`).
- **Self-review before presenting**: after writing a plan and BEFORE calling `ExitPlanMode`, launch a no-chat-context subagent (Plan type) whose prompt contains enough background to review the plan standalone — point it at the plan file and any reference files, and ask it to find issues and improvements (return a report, not edits). Apply the needed changes to the plan, then add the literal marker line `<!-- plan-reviewed -->` to the plan file. Only then call `ExitPlanMode`. The `plan-review-gate.py` hook blocks `ExitPlanMode` until that marker is present.

## Post-Implementation Blind Review
- After implementation is complete (tests green, work committed) and BEFORE running `/simplify` or `/code-review`, spawn a blind subagent (no conversation context) to review the actual code changes.
- The subagent prompt must contain: the plan file path, the git diff of the changes, and the goal — nothing from the current conversation. Ask it to find bugs, design issues, and deviations from the plan. Return a findings report, not edits.
- Apply any valid findings, then proceed to `/simplify` → `/code-review` → PR.

## Memory storage notes (Claude-specific)
- Auto-memory lives in `~/.claude/projects/<slug>/memory/`, indexed by `MEMORY.md`. This is the Claude-native store referenced in the shared rules under "agent-native memory."
- Repo `CLAUDE.md` is the per-repo overlay; in repos with both `CLAUDE.md` and `AGENTS.md`, `CLAUDE.md` should be a symlink to `AGENTS.md` (so both agents read the same content) unless there's a real Claude-only carve-out.
