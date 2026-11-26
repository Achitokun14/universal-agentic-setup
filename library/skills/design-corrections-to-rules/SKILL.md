---
name: design-corrections-to-rules
description: "Use at session end, when asked, to turn the user's design corrections into rules with reasons in DESIGN.md"
---

# Design corrections to rules

Every correction the user makes is taste the agent lacked. If it is not written down, the next session repeats the mistake. This skill finds the corrections, turns each into a rule with its reason, and proposes where to write it. It writes rules only; it never edits component code and never adds a rule the user did not express.

## Rules

1. Only the user's taste. Each rule traces to something the user said, edited, or confirmed. Good-practice rules you would add are your taste, which is what was being corrected.
2. Never invent a "why". If none was given, propose one marked *inferred* and get it confirmed before writing; a wrong why gets extended to cases it does not fit.
3. Propose, then stop. Write only what the user approves.
4. Prefer a check to a sentence: if a violation can be found by matching code (banned value, raw hex instead of a token, forbidden property), propose a lint rule, token restriction or test in addition to a one-line rule that records the why.
5. Write for an agent that was not here: no "as discussed" or "the card from earlier"; name the class of component, the value, the token, the file.
6. Scope of reading: the current conversation. Read earlier session transcripts only if the user names them explicitly. Do not browse other directories for history.
7. Do not edit agent configuration files (AGENTS.md, CLAUDE.md, settings). If DESIGN.md is not referenced from the project's agent instructions, tell the user the one-line pointer to add themselves.

## Procedure

1. **Collect.** Five signals: explicit correction ("no, semi-transparent shadow, not a border"); silent edit (user changed `duration: 400` to `200` in a file you wrote; notice files changed outside your edits); repeated nudge ("smaller" then "still too big": record where they landed, not the steps); revert or rejection (undo, picking variant B, deleting something you added: the why usually needs asking); confirmed non-obvious choice (record only if a fresh agent would plausibly do otherwise). Capture exact words or diff, what you did, what they wanted, any reason. Skip functional bugs, one-screen copy, and misunderstandings of the task.
2. **Filter** each: would a fresh agent building a DIFFERENT component repeat it? No -> skip. Existing rule already says it -> the rule failed, rewrite stricter (a number, a token, "never") rather than duplicate. Existing rule contradicts -> show both, the user picks. Applies everywhere by the user's word -> ask where their global rules live; if that is an agent configuration file (AGENTS.md, CLAUDE.md, settings), give the user the exact text to paste and do not write it; otherwise project rule.
3. **Generalize** to the narrowest level that would have prevented the next, different mistake: instance (too narrow), class (write this: "raised surfaces (cards, popovers, menus) use `shadow-raised`, never a solid border"), universal (too broad: "never use borders"). Two components with the same correction is evidence for class level. Use this codebase's values and token names; say always/never, not prefer/try (soft wording only when the user framed a preference). Self-test: someone who sees only the rule and its why must produce what the user wanted.
4. **Place.** Check candidate -> lint/token/test plus one-line rule. Otherwise DESIGN.md at the repo root under Surfaces, Color, Typography, Spacing and layout, Motion, Interaction or Copy (create it if missing). If one section grows past about 40 lines and applies only to some tasks (motion rules do not matter for a settings form), propose moving the whole section into a project skill with a one-line pointer left behind (creating that skill needs the user's explicit approval, like any write).
5. **Report and stop**, then write only approved items and show the diff. If a new check flags existing code, report the count and ask whether it should warn or whether to fix violations; never fix without asking.

## Entry format

```md
- **Raised surfaces use `shadow-raised`, never a solid border.**
  Why: a solid border makes a raised surface flat and heavy; a semi-transparent shadow adapts to both themes.
  <!-- 2026-11-12: "no, semi-transparent shadow, not a border" -->
```

The comment keeps the date and the user's words so later conflicts show which rule is newer.

## Report format

Sections: Rules to add (`# | You said | Rule | Why | Where`); Needs your answer (each inferred why, ambiguous level, global-vs-project); Conflicts (existing rule, new correction, your pick); Make it a check (exact rule config/test and what it would flag now); Skipped (one line each so the user can override). Close with: "Say `write all` or `write 1, 3`, and answer the questions above." No corrections in the session: say so in one line; that is a good result.

A prune pass (merge duplicates, fix contradictions, tighten vague rules in DESIGN.md) follows the same propose-then-stop rule.

Provenance: see `SOURCES.md`.
