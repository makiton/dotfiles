# Repository rules (chezmoi source — local only)

This file lives **only in this git repository**. It is not part of the chezmoi-managed files synced to `$HOME` via `dot_gemini`. Use it for instructions that should apply when Antigravity / Gemini is opened **on this dotfiles repo**.

## Chezmoi

- This directory is the **chezmoi source state** (`dot_*` → dotfiles under `$HOME`).
- Use the **chezmoi** CLI: `chezmoi add`, `chezmoi apply` (try `--dry-run` first), `chezmoi diff`, `chezmoi edit`, `chezmoi doctor`.
- Do not satisfy requests by only editing files in `$HOME` when the right fix is to change this source tree and apply with chezmoi.
- After source edits, prefer **`chezmoi apply`** so the destination stays in sync.

## Git

- Version changes here with git as you would any other repository.
