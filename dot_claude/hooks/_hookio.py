"""Shared stdin/stdout plumbing for the ~/.claude hooks.

The hooks are standalone scripts wired into ~/.claude/settings.json, but they all
speak the same harness JSON contract on both ends. That contract fails SILENTLY —
a deny envelope the harness no longer recognises is simply ignored, turning a
safety gate off with no error — so it lives here once instead of in three copies.

Importing this from a hook (the scripts run with an arbitrary cwd):

    import os, sys
    sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
    from _hookio import allow, deny, read_payload

FAIL-OPEN CONTRACT: a broken hook must never wedge the tool it gates. Everything
here either allows or emits a well-formed deny; nothing raises on bad input. If
this module itself goes missing the import raises, the hook exits 1, and the
harness treats a non-2 exit as a non-blocking error — loud on stderr, tool still
proceeds. That is deliberate: a broken install should be noisy but not blocking.
"""
import json
import sys

# read_payload() on_error modes.
ALLOW = "allow"  # unparseable envelope -> exit 0 now, tool proceeds
EMPTY = "empty"  # unparseable envelope -> return {}, caller decides


def allow() -> None:
    """Silent passthrough: the tool call proceeds."""
    sys.exit(0)


def deny(reason: str, prefix: str = None) -> None:
    """Emit the PreToolUse deny envelope and exit.

    Exits 0, not non-zero: the decision travels in the JSON body, and a non-zero
    exit would be read as a hook *error* rather than a deny.
    """
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (prefix or "") + reason,
        }
    }))
    sys.exit(0)


def read_payload(on_error: str = ALLOW) -> dict:
    """Parse the hook envelope from stdin; always returns a dict (or exits).

    `on_error` picks what a malformed or non-object envelope means for THIS hook,
    because the two kinds of hook want opposite things:

      ALLOW (default) — filters like git-safety and block-secret-dumps. With no
        parseable command there is nothing to match against, so denying would be
        a spurious block on garbage input.

      EMPTY — gates like plan-review-gate, which enforce "prove you did the step"
        rather than matching a pattern. Returning {} lets the gate run its own
        fallbacks and reach its own conclusion instead of being disarmed by a
        malformed envelope. (Such a gate may still choose to allow afterwards —
        that is its call to make explicitly, not an accident of parsing.)

    Note both modes are fail-open at the boundary; the difference is only WHO
    decides. Nothing here ever denies on its own.
    """
    try:
        raw = sys.stdin.read()
    except (OSError, ValueError):  # closed/unreadable stdin
        raw = ""

    try:
        payload = json.loads(raw or "{}")
    except ValueError:  # JSONDecodeError subclasses ValueError
        payload = None

    # A bare list/string/number/null is well-formed JSON but not an envelope;
    # treat it exactly like a parse failure so callers can assume a dict.
    if not isinstance(payload, dict):
        if on_error == EMPTY:
            return {}
        allow()

    return payload
