# Global Codex rules

These are user-level defaults intended to apply to all projects.

## Session start (git)

`~/.codex/hooks.json` runs `~/.claude/hooks/git-sync-main.sh` on SessionStart (`startup` and `resume`) so `origin` is fetched and `main`/`master` is fast-forwarded when you are on that branch.

Hooks require `[features] codex_hooks = true` in `~/.codex/config.toml`. If you already use `config.toml`, merge that flag in instead of replacing the file.

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
