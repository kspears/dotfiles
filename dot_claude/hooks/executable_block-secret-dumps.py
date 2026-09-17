#!/usr/bin/env python3
"""Pre-Bash hook: deny commands obviously designed to spill secrets.

Reads a PreToolUse JSON envelope on stdin; if the command matches any of the
known secret-dumping patterns, returns a permissionDecision=deny payload with
a short reason hinting at a safer alternative. Otherwise exits 0 silently so
the tool call proceeds.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
from _hookio import allow, deny, read_payload  # noqa: E402

PREFIX = "blocked by secret-dump filter: "

PATTERNS = [
    (
        re.compile(r"\bsystemctl\s+show\b", re.I),
        "`systemctl show` dumps every unit property including Environment= values "
        "that may carry API keys. Use `systemctl is-active`, `systemctl is-enabled`, "
        "or `systemctl status --no-pager -n 0` (omits Environment) instead.",
    ),
    (
        re.compile(r"/proc/\d*/environ"),
        "/proc/<pid>/environ contains the process's environment — including secret "
        "env vars. Use ps/pgrep for existence checks instead.",
    ),
    (
        re.compile(r"\bansible-vault\s+view\b", re.I),
        "`ansible-vault view` decrypts and prints secrets to stdout. Use "
        "`ansible-vault edit` (the editor isolates value visibility) or check "
        "the encrypted ciphertext via grep without view.",
    ),
    (
        re.compile(r"\bkubectl\s+get\s+secrets?\b.*(?<!\w)-o\s+(?:yaml|json)\b", re.I),
        "`kubectl get secret -o yaml/json` prints base64-encoded secret values. "
        "For existence checks use `kubectl get secret <name>` without -o; for a "
        "single field decode with `--template` or a narrow jsonpath.",
    ),
    (
        re.compile(r"\bop\s+(?:read|item\s+get)\b", re.I),
        "`op read` / `op item get` retrieves secret values from 1Password into the "
        "shell. Don't fetch secret values into the transcript; ask the user to paste "
        "the value directly when actually needed.",
    ),
    (
        re.compile(r"\bssh\b[^|;&]*\b(?:printenv|env)\b(?!\s*[A-Z_]+=)", re.I),
        "Remote `printenv` or bare `env` over ssh lists the remote shell's "
        "environment including secrets. Inspect specific values via the "
        "application, not the shell.",
    ),
]


def main() -> None:
    # Fail open on malformed envelopes — better than spurious blocks.
    env = read_payload()

    cmd = (env.get("tool_input") or {}).get("command", "")
    if not isinstance(cmd, str) or not cmd:
        allow()

    for regex, reason in PATTERNS:
        if regex.search(cmd):
            deny(reason, PREFIX)
    # No match — silent passthrough.


if __name__ == "__main__":
    main()
