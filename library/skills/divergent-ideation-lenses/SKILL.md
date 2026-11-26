---
name: divergent-ideation-lenses
description: "Use for open-ended, high-stakes ideation, test-strategy or pre-launch audits needing non-default options"
---

# Divergent ideation with isolated lenses

One context window brainstorms linearly: ideas bleed together and settle on the few most common patterns. This skill spreads the thinking across isolated subagents, each with a different lens, then has a skeptical critic pick the non-obvious survivors.

Not for quick fixes or questions with a known standard answer. For a yes/no choice between a few known options use a council/vote skill (if installed); for requirement questions use an interview-style requirements skill (if installed).

## Pre-check (answer all three; any "no" means answer normally)

1. Is the task open-ended, with many valid directions?
2. Are the stakes high enough that a default answer would cost something?
3. Did the user avoid asking for "quick", "standard" or "just the usual"?

## Procedure

1. **Frame** the problem in a self-contained brief: goal, constraints, known defaults, what "good" means. State it in one paragraph; add the files or facts a stranger would need.
2. **Choose lenses.** Five by default, each a distinct way of looking (see `references/lenses.md`). Write one line per lens before spawning.
3. **Fan out.** One subagent per lens (if the agent supports subagents; otherwise one fresh session per lens, run in turn), in parallel where possible, each given ONLY the brief and its lens, never the other lenses' output or this conversation. Ask each for 5 to 6 concrete directions, each with a one-line mechanism and its main risk.
4. **Critic pass.** One fresh read-only subagent or session acts as a skeptical senior engineer. It scores every direction 1-10 on Novelty, Viability and Fit (for example `N9 V8 F10`), discards the obvious first defaults, and writes a Trap List: concrete ways the surviving options fail.
5. **Select** the top 3 non-obvious directions with scores, mechanism, trap list items and a first step each. Say which defaults were dropped and why. The user chooses; do not start building on your own pick when the stakes are high.

## Applications

- **Orthogonal test strategy:** from a PRD and tech spec, before coding, produce three test suites that cover different ground (edge cases, performance/load, failure and abuse). See `references/lenses.md`.
- **Pre-launch audit:** read the PRD and the finished app; list promises the app does not deliver and moments likely to make users leave. Read-only; findings only, no edits.

## Never

- Let lens agents see each other's output (that recreates the single window).
- Count ideas as quality: ten variants of one idea is one idea.
- Run code, send messages, or change the project inside lens or critic passes.

## References

- `references/lenses.md`: load at step 2 for example lenses, the critic prompt and the two application briefs.

Distilled from compendium notes on an ADHD-style divergent ideation skill; only the stated behaviour is used. Own words.
