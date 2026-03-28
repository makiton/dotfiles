# Global Claude rules

These are user-level defaults intended to apply to all projects.

## Operating principles

- Be direct and pragmatic. Prefer small, correct changes over large refactors.
- Ask a question when requirements are ambiguous or when an action is risky/destructive.
- When modifying code, keep diffs minimal and consistent with existing conventions.

## Engineering defaults

- Prefer deterministic behavior over "best effort" heuristics.
- Add tests when the repo already has a test harness and the change is non-trivial.
- Avoid introducing new dependencies unless there is a clear payoff.

## Communication

- Summarize what you changed and how to verify it.
- If you could not run tests/build, say so explicitly.

