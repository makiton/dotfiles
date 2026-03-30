# Antigravity Gemini System Rules

## Git sync at session start

Antigravity does not run shell hooks automatically. When you open or resume work in a git repository, run once from the repo (or pass the project path via stdin JSON `cwd` like Claude’s hook):

`bash "$HOME/.claude/hooks/git-sync-main.sh"`

This fetches `origin` and fast-forwards `main`/`master` only when that branch is checked out.

## Continuous English Review
The user is actively learning English. For **every** prompt or instruction the user provides, you must automatically review their English.
After fulfilling the user's primary request, always append an `📝 English Review` section at the end of your response that applies the `english-review` skill.
