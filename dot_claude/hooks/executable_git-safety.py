#!/usr/bin/env python3
"""Pre-Bash hook: enforce git-safety rules the allowlist would otherwise auto-approve.

Reads a PreToolUse JSON envelope on stdin. Denies (with a short reason) commands
that violate four rules:

  1. Commit on main/master       — create a branch first (opt-out per repo).
  2. Force push                  — --force / -f / --force-with-lease.
  3. Destructive commands        — rm -rf, git reset --hard, git clean -fd,
                                   truncate, mkfs, dd of=/dev/*, DROP TABLE/DATABASE.
  4. Staging/committing secrets  — .env, *.pem, id_rsa, vault files, etc.

Detection is segment- and flag-aware so chains (`git add . && git commit`) and
global options (`git -C /path commit`) don't slip past. Fails OPEN on malformed
input or git errors — a spurious block is worse than a missed edge case.
"""
import fnmatch
import os
import re
import shlex
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
from _hookio import allow, read_payload  # noqa: E402
from _hookio import deny as _deny  # noqa: E402

GIT_TIMEOUT = 5  # seconds — a hung git must not stall every Bash call

# git global options that consume the FOLLOWING token as their argument; we skip
# both so the real subcommand isn't misread (e.g. `git -C /path commit`).
GIT_GLOBAL_ARG_OPTS = {
    "-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path",
    "--super-prefix",
}

SECRET_GLOBS = [
    ".env", ".env.*", "*.env",
    "*.pem", "*.key", "*.p12", "*.pfx",
    "id_rsa", "id_dsa", "id_ecdsa", "id_ed25519",
    "*vault*.yml", "*vault*.yaml",
    "*credentials*",
]

# Template/placeholder files that conventionally hold only dummy values and are
# meant to be committed — exempt them even when they match a secret glob
# (e.g. .env.example matches ".env.*").
EXAMPLE_GLOBS = [
    "*.example", "*.example.*",
    "*.sample", "*.sample.*",
    "*.template", "*.template.*",
    "*.dist", "*.tmpl",
]

# Commit-message flags whose VALUES we must not scan for destructive substrings.
# (Deliberately NOT -c/-C — those are global flags like `psql -c`/`bash -c` whose
# contents we DO want to inspect; git's commit-reuse -c/-C take a ref, not free text.)
MSG_FLAGS_WITH_ARG = {"-m", "--message", "-F", "--file"}

# Commands that EXECUTE SQL — DROP TABLE/DATABASE is only dangerous through one of
# these, so we scope the check to them (avoids blocking `grep "DROP TABLE"`).
SQL_CLIENTS = {"psql", "mysql", "mariadb", "sqlite3", "sqlite", "cockroach", "usql"}


def deny(reason: str) -> None:
    """Emit the PreToolUse deny envelope and exit — every rule below calls this."""
    _deny(reason, "blocked by git-safety hook: ")


def split_segments(command: str):
    """Split a compound command into segments on &&, ||, ;, |, and newlines."""
    return re.split(r"&&|\|\||;|\n|\|", command)


def tokenize(segment: str):
    """shlex-split a segment; return None if it can't be parsed."""
    try:
        return shlex.split(segment)
    except ValueError:
        return None


def is_git(token: str) -> bool:
    base = token.lstrip("\\")
    return base == "git" or base.rsplit("/", 1)[-1] == "git"


def parse_git(tokens):
    """Return (subcommand, repo_from_dash_C) for a git invocation, else (None, None).

    Skips global options — including those that take a separate argument — so the
    first real subcommand is identified correctly.
    """
    n = len(tokens)
    for i, tok in enumerate(tokens):
        if not is_git(tok):
            continue
        repo_c = None
        j = i + 1
        while j < n:
            t = tokens[j]
            if t == "-C" and j + 1 < n:
                repo_c = tokens[j + 1]
                j += 2
                continue
            if t in GIT_GLOBAL_ARG_OPTS and j + 1 < n:
                j += 2
                continue
            if t.startswith("-"):  # standalone global flag (e.g. --no-pager) or --opt=val
                j += 1
                continue
            return t, repo_c  # first bare token = subcommand
        return None, repo_c
    return None, None


def resolve_repo(repo_c, envelope) -> str:
    if repo_c:
        return repo_c
    cwd = envelope.get("cwd")
    if isinstance(cwd, str) and cwd:
        return cwd
    return os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()


def run_git(repo: str, *args):
    """Run a git command in repo; return stripped stdout, or None on any failure."""
    try:
        res = subprocess.run(
            ["git", "-C", repo, *args],
            capture_output=True, text=True, timeout=GIT_TIMEOUT,
        )
    except (subprocess.SubprocessError, OSError):
        return None
    if res.returncode != 0:
        return None
    return res.stdout.strip()


VAULT_MAGIC = "$ANSIBLE_VAULT;"


def is_vault_ciphertext(text) -> bool:
    """True if text is an ansible-vault encrypted payload (its 1.x header line)."""
    return isinstance(text, str) and text.lstrip().startswith(VAULT_MAGIC)


def read_head(path: str):
    """First line of a file on disk, or None if unreadable."""
    try:
        with open(path, "r", errors="replace") as fh:
            return fh.readline()
    except OSError:
        return None


def encrypted_vault(p: str, repo=None, check_staged=True) -> bool:
    """True if the bytes actually being committed/staged are vault ciphertext.

    For a commit, the staged blob is authoritative — that is what gets recorded, and
    it can differ from disk (stage plaintext, then encrypt the working copy). For
    `git add` the staged blob is the *previous* content, so only disk is meaningful;
    callers pass check_staged=False there.
    """
    if repo and check_staged:
        staged = run_git(repo, "show", ":" + p)
        if staged is not None:
            return is_vault_ciphertext(staged)
    for cand in ([os.path.join(repo, p)] if repo else []) + [p]:
        head = read_head(cand)
        if head is not None:
            return is_vault_ciphertext(head)
    return False


def secret_paths(paths, repo=None, check_staged=True):
    """Return the subset of paths whose basename/path matches a secret glob."""
    hits = []
    for p in paths:
        base = p.rsplit("/", 1)[-1]
        if any(fnmatch.fnmatch(base, g) or fnmatch.fnmatch(p, g) for g in EXAMPLE_GLOBS):
            continue
        if any(fnmatch.fnmatch(base, g) or fnmatch.fnmatch(p, g) for g in SECRET_GLOBS):
            # An ansible-vault file is encrypted at rest and belongs in git; a
            # plaintext one matching the same glob still gets blocked.
            if encrypted_vault(p, repo, check_staged):
                continue
            hits.append(p)
    return hits


# --- flag helpers ----------------------------------------------------------
def short_letters(tok: str) -> str:
    """For a short-flag cluster like '-rf' return 'rf'; '' for long/non-flags."""
    if tok.startswith("-") and not tok.startswith("--"):
        return tok[1:]
    return ""


def has_recursive(flags) -> bool:
    return any("--recursive" == f or ("r" in short_letters(f)) or ("R" in short_letters(f))
               for f in flags)


def has_force(flags) -> bool:
    return any("--force" == f or ("f" in short_letters(f)) for f in flags)


# --- checks ----------------------------------------------------------------
def check_commit_on_main(repo: str):
    sentinel = os.path.join(repo, ".claude", "allow-main-commits")
    if os.path.exists(sentinel):
        return
    branch = run_git(repo, "symbolic-ref", "--short", "HEAD")
    if branch in ("main", "master"):
        deny(
            f"this would commit directly to '{branch}'. Create a feature branch first "
            f"(git switch -c fix/... or feat/...) and commit there. To exempt this repo, "
            f"create {os.path.join('.claude', 'allow-main-commits')}."
        )


def check_staged_secrets(repo: str, amend_all: bool):
    names = run_git(repo, "diff", "--cached", "--name-only")
    paths = names.splitlines() if names else []
    if amend_all:
        unstaged = run_git(repo, "diff", "--name-only")
        if unstaged:
            paths += unstaged.splitlines()
    hits = secret_paths(paths, repo)
    if hits:
        deny(
            "this commit includes secret-shaped files: " + ", ".join(sorted(set(hits)))
            + ". Remove them from the index (git restore --staged <f>) and add them to "
            ".gitignore — secrets belong in 1Password / Ansible Vault, not git."
        )


def check_force_push(flags):
    for f in flags:
        if f in ("--force", "--force-with-lease") or f.startswith("--force-with-lease="):
            deny(
                "force-push is disabled without explicit approval (including "
                "--force-with-lease). If this is intentional, run it yourself in a terminal."
            )
        if "f" in short_letters(f):
            deny(
                "force-push (-f) is disabled without explicit approval. If intentional, "
                "run it yourself in a terminal."
            )


def check_add_secrets(tokens, repo=None):
    """Best-effort: deny `git add <literal-secret-path>` (globs/`.` won't be caught)."""
    args = [t for t in tokens if not t.startswith("-")]
    hits = secret_paths(args, repo, check_staged=False)
    if hits:
        deny(
            "staging secret-shaped files: " + ", ".join(sorted(set(hits)))
            + ". Don't add secrets to git — use 1Password / Ansible Vault."
        )


def strip_message_args(tokens):
    """Drop commit-message flag values so 'fix rm -rf bug' isn't scanned as a command."""
    out = []
    skip_next = False
    for t in tokens:
        if skip_next:
            skip_next = False
            continue
        if t in MSG_FLAGS_WITH_ARG:
            skip_next = True
            continue
        if t.startswith("--message=") or t.startswith("--file="):
            continue
        if re.match(r"^-[a-zA-Z]*m.+", t):  # -m"msg" combined cluster
            continue
        out.append(t)
    return out


def check_destructive(tokens):
    toks = strip_message_args(tokens)
    n = len(toks)

    # rm with recursive AND force (path-prefixed / backslash-escaped ok)
    for i, t in enumerate(toks):
        base = t.lstrip("\\").rsplit("/", 1)[-1]
        if base == "rm":
            flags = [x for x in toks[i + 1:] if x.startswith("-")]
            if has_recursive(flags) and has_force(flags):
                deny("`rm -rf`-style recursive force delete is disabled without approval.")

    # dd writing to a block device
    if any(re.match(r"of=/dev/", t) for t in toks):
        deny("`dd` writing to a block device (of=/dev/*) is disabled without approval.")

    # truncate / mkfs as commands
    for t in toks:
        base = t.lstrip("\\").rsplit("/", 1)[-1]
        if base in ("mkfs",) or base.startswith("mkfs."):
            deny("`mkfs` (filesystem creation) is disabled without approval.")
        if base == "truncate":
            deny("`truncate` is disabled without approval (can zero out files).")

    # git reset --hard / git clean -fd
    sub, _ = parse_git(toks)
    if sub == "reset" and "--hard" in toks:
        deny("`git reset --hard` discards changes irreversibly — disabled without approval.")
    if sub == "clean":
        flags = [x for x in toks if x.startswith("-")]
        if has_force(flags) and any(
            ("d" in short_letters(f) or "x" in short_letters(f)) for f in flags
        ):
            deny("`git clean -fd/-fx` deletes untracked files — disabled without approval.")


def check_sql_drop(segment: str, tokens):
    """Deny DROP TABLE/DATABASE only when a SQL client actually runs it."""
    invokes_sql = any(
        t.lstrip("\\").rsplit("/", 1)[-1] in SQL_CLIENTS for t in (tokens or [])
    )
    if not invokes_sql:
        return
    if re.search(r"\bDROP\s+(TABLE|DATABASE)\b", segment, re.I):
        deny(
            "`DROP TABLE/DATABASE` via a SQL client is disabled without approval. "
            "Run it yourself if intended."
        )


def main() -> None:
    envelope = read_payload()  # fail open on a malformed envelope

    cmd = (envelope.get("tool_input") or {}).get("command", "")
    if not isinstance(cmd, str) or not cmd:
        allow()

    for segment in split_segments(cmd):
        if not segment.strip():
            continue
        tokens = tokenize(segment)
        if tokens is None:
            continue  # couldn't parse quoting — fail open

        check_destructive(tokens)
        check_sql_drop(segment, tokens)

        sub, repo_c = parse_git(tokens)
        if sub is None:
            continue
        repo = resolve_repo(repo_c, envelope)

        if sub == "push":
            flags = [t for t in tokens if t.startswith("-")]
            check_force_push(flags)
        elif sub == "commit":
            check_commit_on_main(repo)
            amend_all = any(
                t in ("-a", "--all") or re.match(r"^-[a-zA-Z]*a", t) for t in tokens
            )
            check_staged_secrets(repo, amend_all)
        elif sub == "add":
            check_add_secrets(tokens, repo)

    # No rule matched — silent passthrough.


if __name__ == "__main__":
    main()
