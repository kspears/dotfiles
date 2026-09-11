# ~/.agents — Shared Rules, Skills, and Scripts

Single source of truth for cross-agent configuration. Anything that should apply to multiple coding agents (Claude Code, Codex CLI, future tinkering) lives here; each agent's native config reads from this directory.

This directory is managed by chezmoi as `dot_agents/` in `~/code/dotfiles` — see **Editing** below.

## Layout

```
~/.agents/
├── shared/
│   ├── rules.md          # agent-agnostic global rules (personality, git, safety, …)
│   └── skills/           # portable prompted skills (one dir per skill, SKILL.md inside)
│       ├── README.md
│       ├── code-improver/         # SKILL.md + agents/openai.yaml (Codex metadata)
│       ├── security-reviewer/
│       └── interview-to-spec/
├── claude/
│   └── overlay.md        # Claude Code–only additions (planning, model strategy, plans dir)
├── codex/                # reserved for Codex-only additions if any emerge
└── scripts/              # shared shell scripts wired into each agent's hooks separately
```

## How each agent picks this up

### Rules

| Agent | Mechanism |
| --- | --- |
| Claude Code | `~/.claude/CLAUDE.md` contains two `@`-imports: `@~/.agents/shared/rules.md` then `@~/.agents/claude/overlay.md` |
| Codex CLI | `~/.codex/config.toml` sets `model_instructions_file = "/Users/kevin/.agents/shared/rules.md"`. `~/.codex/AGENTS.md` is also a symlink to the same file (chezmoi-managed via `dot_codex/symlink_AGENTS.md.tmpl`). |
| Cursor | `~/.cursor/rules/global.mdc` is **generated** by chezmoi from `dot_cursor/rules/global.mdc.tmpl`, which `include`s `shared/rules.md` verbatim under `alwaysApply: true` frontmatter. Deployed on the `work` machine only (gated in `.chezmoiignore`) — Cursor isn't used at home. Never edit the `.mdc` by hand; it is overwritten on every `chezmoi apply`. |
| `~/AGENTS.md` | Symlink to `~/.agents/shared/rules.md` (chezmoi-managed via `symlink_AGENTS.md.tmpl`) — for any agent that walks up to `$HOME` looking for AGENTS.md. |

### Per-repo rules

- Canonical file is `<repo>/AGENTS.md`.
- `<repo>/CLAUDE.md` is a symlink to `AGENTS.md` when the rules are identical (current homelab convention). Use `@AGENTS.md` import + overlay only when a real Claude-specific carve-out is needed.

### Skills

| Agent | Mechanism |
| --- | --- |
| Codex CLI | `~/.codex/skills/<name>` is a symlink to `~/.agents/shared/skills/<name>` |
| Claude Code | `~/.claude/skills/<name>` is a symlink to `~/.agents/shared/skills/<name>`. `~/.claude/agents/<name>.md` (subagents) remains a separate, incompatible format; `adversary` and `verifier` are tracked as `dot_claude/agents/`. |

### Memory

- **Claude auto-memory** stays in `~/.claude/projects/<slug>/memory/` (Claude-native, Claude writes it).
- **ATLAS** (`forge` MCP `memory_*`) is the cross-agent persistent store. Both Claude Code and Codex CLI have the `forge` MCP server configured in their respective settings; either agent can read/write the same memory there.

### Hooks

Not unified — Claude Code and Codex have incompatible hook schemas. Shell scripts go in `~/.agents/scripts/`; each agent's hook config calls them separately.

## Adding a new shared skill

1. Create `~/.agents/shared/skills/<name>/SKILL.md` with minimal frontmatter (`name`, `description`), plus `agents/openai.yaml` with Codex's `display_name`, `short_description`, and `default_prompt` (copy an existing one).
2. Write the body as if no specific agent's tool names are available — speak generically about reading files, running commands, etc.
3. Add `dot_codex/skills/symlink_<name>.tmpl` and `dot_claude/skills/symlink_<name>.tmpl` to the dotfiles repo, each containing `{{ .chezmoi.homeDir }}/.agents/shared/skills/<name>`, then `chezmoi apply`. Both agents discover the skill through the symlink.

## Editing

`~/.agents/` is a chezmoi-managed **copy**, not a symlink into the repo. So editing a live file here leaves the repo stale. Two safe paths:

- `chezmoi edit ~/.agents/shared/rules.md` — edits the source, then `chezmoi apply` to push it live.
- Edit `~/.agents/...` directly, then `chezmoi add ~/.agents` to re-import.

Either way, `chezmoi status` should be clean before you commit. An `MM` on a file here means the two copies have drifted — that is exactly the failure this layout is meant to prevent.

## Adding a new shared rule

Edit `shared/rules.md` (per **Editing** above). Claude and Codex pick it up on next session; Cursor picks it up on the next `chezmoi apply` at work. No per-agent edits required.

## Known followups

- Codex has been unused since 2026-06-22. Wiring is kept because it costs nothing; drop it if that stays true.

## Backups

Originals preserved with `.bak-YYYYMMDD-HHMMSS` suffixes when this system was set up:
- `~/.claude/CLAUDE.md.bak-20260522-071511` and `.bak-20260807-133418`
- `~/.codex/memories/global-instructions.md.bak-20260522-071541`
- `~/.codex/AGENTS.md.bak-20260522-071558` (was an empty file)

The `~/code/homelab/` backup is already gone. These are unmanaged by chezmoi and safe to delete — the repo is the real backup now.
