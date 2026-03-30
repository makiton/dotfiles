#!/usr/bin/env bash
# SessionStart hook: fetch origin and fast-forward the default branch when checked out on it.
# Used by Claude Code and Codex; safe to run manually from a repo (uses cwd when stdin is a TTY).

set -u

# Read JSON from stdin when attached to a pipe (Claude/Codex SessionStart).
if ! [ -t 0 ]; then
  INPUT=$(cat)
  if command -v jq >/dev/null 2>&1 && [ -n "$INPUT" ]; then
    CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
    if [ -n "$CWD" ] && [ "$CWD" != null ]; then
      cd "$CWD" 2>/dev/null || exit 0
    fi
  fi
fi

git rev-parse --git-dir >/dev/null 2>&1 || exit 0
git remote get-url origin >/dev/null 2>&1 || exit 0

MAIN_BRANCH=""
for name in main master; do
  if git show-ref --verify --quiet "refs/remotes/origin/$name" 2>/dev/null; then
    MAIN_BRANCH=$name
    break
  fi
done
if [ -z "$MAIN_BRANCH" ]; then
  exit 0
fi

GIT_TERMINAL_PROMPT=0 git fetch origin "$MAIN_BRANCH" --prune 2>/dev/null || exit 0

current=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
if [ "$current" != "$MAIN_BRANCH" ]; then
  exit 0
fi

if ! GIT_TERMINAL_PROMPT=0 git merge --ff-only "origin/$MAIN_BRANCH" 2>/dev/null; then
  echo "git-sync-main: could not fast-forward ${MAIN_BRANCH} (local commits, merge needed, or conflicts)." >&2
fi

exit 0
