#!/usr/bin/env python3
"""Pre-ExitPlanMode hook: require a subagent review before a plan can be presented.

Workflow (see the "Plans" section of ~/.claude/CLAUDE.md): after writing a plan and before
calling ExitPlanMode, launch a no-context Plan subagent to review it, apply the fixes,
then add the literal marker `<!-- plan-reviewed -->` to the plan file.

Identifying the session's plan file:
  1. `tool_input.planFilePath` from the hook payload — the harness states the path
     outright (present in 91 of 92 historical ExitPlanMode calls; the exception had an
     empty input). This is authoritative and directory-agnostic.
  2. Failing that, the last plan file named in the session transcript — best-effort
     insurance in case the harness stops supplying the path.

Never guesses by mtime: that picks the wrong plan whenever a session touches an older
plan file after writing its own, and a wrong guess makes the model append the marker to
an unrelated plan — disarming that plan's gate and mutating a file the session never
meant to touch. When neither signal is available it fails OPEN with a note on stderr;
a missed gate is better than wedging plan mode or gating the wrong file.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
from _hookio import EMPTY, allow, read_payload  # noqa: E402
from _hookio import deny as _deny  # noqa: E402

MARKER = "<!-- plan-reviewed -->"
PLANS_DIR = os.path.expanduser("~/.claude/plans")

# Any absolute, ~-relative, or repo-relative mention of a plan file; only the basename
# is used, so all three forms resolve to the same place without a second path literal.
_PLAN_NAME = re.compile(r"\.claude/plans/([^\s\"'`)\]/]+\.md)")


def deny(plan: str) -> None:
    _deny(
        "plan-review gate: this plan hasn't been reviewed yet. Before presenting "
        "it, launch a no-chat-context Plan subagent with a self-contained prompt "
        f"to review {plan} (point it at the plan and any reference files; ask for "
        "issues + improvements as a report, not edits). Apply the needed fixes to "
        f"the plan, append the literal line `{MARKER}` to the plan file, then call "
        "ExitPlanMode again."
    )


def plan_from_transcript(path: str):
    """Last plan file named anywhere in the transcript, or None."""
    found = None
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            # Cheap reject: the regex has no literal prefix to anchor on, and scanning
            # every byte of a multi-hundred-MB transcript with it is ~5x slower.
            if "/plans/" not in line:
                continue
            names = _PLAN_NAME.findall(line)
            if names:
                found = names[-1]
    return os.path.join(PLANS_DIR, found) if found else None


def main() -> None:
    # EMPTY, not the default ALLOW: a gate proves a step was taken, so a malformed
    # envelope must not disarm it by short-circuiting past the checks below. It
    # still ends up allowing today (no path, no transcript -> nothing to gate), but
    # that is this function's decision to make, not a side effect of json parsing.
    payload = read_payload(EMPTY)
    try:
        plan = (payload.get("tool_input") or {}).get("planFilePath")

        if not plan:
            print(
                "plan-review-gate: no tool_input.planFilePath in payload; "
                "falling back to transcript scan",
                file=sys.stderr,
            )
            transcript = payload.get("transcript_path")
            plan = plan_from_transcript(os.path.expanduser(transcript)) if transcript else None

        if not plan or not os.path.exists(plan):
            allow()  # nothing trustworthy to gate — never guess
        with open(plan, encoding="utf-8") as fh:
            if MARKER in fh.read():
                allow()
    except (OSError, ValueError, AttributeError):
        allow()  # fail open on any malformed payload or filesystem error

    deny(plan)


if __name__ == "__main__":
    main()
