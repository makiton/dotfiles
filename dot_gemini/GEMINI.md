# Antigravity Gemini System Rules

## Git sync at session start

Antigravity does not run shell hooks automatically. When you open or resume work in a git repository, run once from the repo (or pass the project path via stdin JSON `cwd` like Claude’s hook):

`bash "$HOME/.claude/hooks/git-sync-main.sh"`

This fetches `origin` and fast-forwards `main`/`master` only when that branch is checked out.

## Multi-agent workspaces (git worktrees)

The user often runs **multiple agents at the same time**. Agents must not edit the **same checkout** concurrently.

### Requirement

For **substantive** work in a **git repository** (multi-file changes, features, refactors—not a single trivial edit the user explicitly limits to one file), **use a dedicated git worktree** for this session’s edits unless the workspace is **already** that worktree.

### Procedure

1. **Already in a worktree?** If the workspace path is a linked worktree (`git worktree list` includes it) or lives under a project convention such as `.worktrees/<name>/` or `worktrees/<name>/`, work there and use a **unique branch** per task (e.g. `agent/<short-topic>`). Do not switch the main checkout for heavy work.
2. **Otherwise:** From the **main** repo root, run git sync once if applicable (`bash "$HOME/.claude/hooks/git-sync-main.sh"`), then `git worktree add` a new path and branch. Prefer a parent directory that is **gitignored** (e.g. `.worktrees/`); if it is not ignored, add it to `.gitignore` and commit that fix before creating trees (skill **using-git-worktrees** when available for directory choice and safety checks).
3. **Use** the new tree as the working directory for this session. If you cannot change the workspace root from here, tell the user to **open that path as the project folder** (e.g. editor **File → Open Folder**) or use it consistently as **`cwd`** for shell and file tools so edits do not hit the shared checkout.

### Why worktrees

Parallel agents on one working tree cause clobbered files, tangled `git status`, and bad merges. Worktrees give each agent its own files and branch while sharing one `.git` database.

### Exceptions

Skip a new worktree only when the user clearly asks for a **minimal** change in the **current** path, or when the project is not a git repo.

## Continuous English Review
The user is actively learning English. For **every** prompt or instruction the user provides, you must automatically review their English.
After fulfilling the user's primary request, always append an `📝 English Review` section at the end of your response that applies the `english-review` skill.
