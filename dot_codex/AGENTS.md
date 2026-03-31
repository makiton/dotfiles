# Global Codex rules

These are user-level defaults intended to apply to all projects.

## Session start (git)

`~/.codex/hooks.json` runs `~/.claude/hooks/git-sync-main.sh` on SessionStart (`startup` and `resume`) so `origin` is fetched and `main`/`master` is fast-forwarded when you are on that branch.

Hooks require `[features] codex_hooks = true` in `~/.codex/config.toml`. If you already use `config.toml`, merge that flag in instead of replacing the file.

## Multi-agent workspaces (git worktrees)

The user often runs **multiple agents at the same time**. Agents must not edit the **same checkout** concurrently.

### Requirement

For **substantive** work in a **git repository** (multi-file changes, features, refactors—not a single trivial edit the user explicitly limits to one file), **use a dedicated git worktree** for this session’s edits unless the workspace is **already** that worktree.

### Procedure

1. **Already in a worktree?** If the workspace path is a linked worktree (`git worktree list` includes it) or lives under a project convention such as `.worktrees/<name>/` or `worktrees/<name>/`, work there and use a **unique branch** per task (e.g. `agent/<short-topic>`). Do not switch the main checkout for heavy work.
2. **Otherwise:** From the **main** repo root, rely on session-start sync when applicable, then `git worktree add` a new path and branch. Prefer a parent directory that is **gitignored** (e.g. `.worktrees/`); if it is not ignored, add it to `.gitignore` and commit that fix before creating trees (skill **using-git-worktrees** when available for directory choice and safety checks).
3. **Use** the new tree as the working directory for this session. If you cannot change the workspace root from here, tell the user to **open that path as the project folder** (e.g. editor **File → Open Folder**) or use it consistently as **`cwd`** for shell and file tools so edits do not hit the shared checkout.

### Why worktrees

Parallel agents on one working tree cause clobbered files, tangled `git status`, and bad merges. Worktrees give each agent its own files and branch while sharing one `.git` database.

### Exceptions

Skip a new worktree only when the user clearly asks for a **minimal** change in the **current** path, or when the project is not a git repo.

## Default behavior

- Keep changes small and focused; avoid unrelated refactors.
- Prefer editing existing code paths over adding parallel implementations.
- If a command could be destructive, pause and ask before running it.

## Code quality

- Match existing style and patterns in the repo.
- Add/update tests when the repo already has tests and the change warrants it.
- Avoid adding new dependencies unless necessary.

## Reporting

- State what changed and how to verify (commands, files).
- If tests/build were not run, say so.

## Continuous English Review

The user is actively learning English. For **every** prompt or instruction the user provides, you must automatically review their English.
After fulfilling the user's primary request, always append an `📝 English Review` section at the end of your response.

In this section, always:
1. **Analyze and Suggest**: Point out grammatical errors, spelling mistakes, missing articles, or unnatural phrasing in their prompt.
2. **Provide Alternatives**: Offer 1-2 more natural, native-sounding ways to express the same idea (e.g., Casual and Professional).
3. **Explain Why**: Briefly explain the grammatical rules or nuances behind your suggestions.
4. **Tone Check**: Advise if their phrasing might come across as unintendedly direct or aggressive.
5. **Be Encouraging**: Always maintain a polite, friendly, and helpful tone.
