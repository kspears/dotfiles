#!/usr/bin/env python3
"""Post-Bash hook: scan tool output for secret-shaped values; replace inline.

Reads a PostToolUse JSON envelope on stdin. Walks the tool_response strings
recursively, applies regex substitutions to known secret shapes, and — if
anything matched — returns a `decision=block` result whose `reason` is the
redacted output. That replaces what the model sees with a redacted version,
keeping the structure of the output but blanking the values.

If nothing matched, exits 0 silently and the original output passes through.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
from _hookio import allow, read_payload  # noqa: E402

REDACTED = "[REDACTED]"

# Env-assignment patterns: NAME=value where NAME ends in a secret-bearing suffix.
ENV_ASSIGN = re.compile(
    r"\b([A-Za-z_][A-Za-z0-9_]*(?:_TOKEN|_KEY|_SECRET|_PASS|_PASSWORD))"
    r"(\s*=\s*)"
    r"([^\s\"',]+)",
    re.I,
)

# Known opaque secret shapes — match-and-replace the full token.
SHAPE_PATTERNS = [
    re.compile(r"sk-ant-[A-Za-z0-9_-]{20,}"),                # Anthropic API
    re.compile(r"\bsk-(?:proj-)?[A-Za-z0-9_-]{32,}\b"),       # OpenAI / Codex
    re.compile(r"\bghp_[A-Za-z0-9]{36}\b"),                  # GitHub PAT
    re.compile(r"\bgho_[A-Za-z0-9]{36}\b"),                  # GitHub OAuth
    re.compile(r"\bAKIA[A-Z0-9]{16}\b"),                     # AWS access key
    re.compile(
        r"-----BEGIN [A-Z ]*PRIVATE KEY-----[\s\S]*?-----END [A-Z ]*PRIVATE KEY-----"
    ),  # PEM-encoded private keys (SSH, PGP, etc.)
]


def redact_text(text: str) -> tuple[str, bool]:
    """Return (text, changed). Replace matches with REDACTED."""
    if not isinstance(text, str) or not text:
        return text, False
    changed = False

    def env_repl(m: re.Match) -> str:
        nonlocal changed
        changed = True
        return f"{m.group(1)}{m.group(2)}{REDACTED}"

    text = ENV_ASSIGN.sub(env_repl, text)

    for pat in SHAPE_PATTERNS:
        new_text, n = pat.subn(REDACTED, text)
        if n:
            changed = True
            text = new_text
    return text, changed


def walk_redact(node):
    """Recursively redact strings in dict/list payloads; return (node, changed)."""
    if isinstance(node, dict):
        changed = False
        for k, v in list(node.items()):
            new_v, c = walk_redact(v)
            node[k] = new_v
            changed = changed or c
        return node, changed
    if isinstance(node, list):
        changed = False
        for i, v in enumerate(node):
            new_v, c = walk_redact(v)
            node[i] = new_v
            changed = changed or c
        return node, changed
    if isinstance(node, str):
        return redact_text(node)
    return node, False


def stringify_response(resp) -> str:
    """Best-effort textual reconstruction of a tool_response for the model."""
    if isinstance(resp, str):
        return resp
    if isinstance(resp, dict):
        parts = []
        for key in ("stdout", "output", "result", "content"):
            v = resp.get(key)
            if isinstance(v, str) and v:
                parts.append(v)
        stderr = resp.get("stderr")
        if isinstance(stderr, str) and stderr.strip():
            parts.append("---stderr---\n" + stderr)
        if parts:
            return "\n".join(parts)
    return json.dumps(resp, indent=2)


def main() -> None:
    env = read_payload()  # fail open on a malformed envelope

    resp = env.get("tool_response")
    if resp is None:
        allow()

    _, changed = walk_redact(resp)
    if not changed:
        allow()

    redacted_body = stringify_response(resp)
    reason = (
        "[redact-secrets hook] the tool output contained values matching "
        "secret-bearing patterns (API keys, env-var assignments ending in "
        "_TOKEN/_KEY/_SECRET/_PASS/_PASSWORD, or PEM private keys). Values "
        "replaced with [REDACTED]. Redacted output follows:\n\n"
        + redacted_body
    )
    print(json.dumps({"decision": "block", "reason": reason}))


if __name__ == "__main__":
    main()
