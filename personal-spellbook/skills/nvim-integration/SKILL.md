---
name: nvim-integration
description: Open files in the user's running neovim instance via nvr. Use when asked to open a file for editing or review.
---

# Neovim Integration

The user runs neovim with named server sessions. Each nvim instance listens on a Unix socket at `/tmp/nvim-<session>.sock` (e.g. `/tmp/nvim-lola.sock`, `/tmp/nvim-notes.sock`).

## Opening files in nvim

Use `nvr` to open files in the user's running neovim:

```bash
nvr --servername /tmp/nvim-<session>.sock --remote <filepath>
```

- To find available sockets, run: `ls /tmp/nvim-*.sock`
- Common sessions: `notes` (~/Documents/Notes), `lola`, `quantext`, plus project-named sessions.
- Pick the socket that matches the context (e.g. notes files → `nvim-notes.sock`, code files → project session socket).
- When the user asks you to open a file for review, send it to their nvim rather than just printing the path.
- If no socket exists, fall back to telling the user the file path.
