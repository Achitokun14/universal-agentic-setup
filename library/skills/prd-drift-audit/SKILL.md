---
name: prd-drift-audit
description: "Use when agent-built code may have drifted from its written spec files, or before building an MVP."
---

# PRD drift audit

Keep fast agent-built code aligned with written requirements: spec-first MVP gate, then a per-requirement audit plus a hunt for unrequested features.

## Spec-first MVP gate (new projects)
1. Propose `specs/PRD.md` (core features, scope, non-goals) and create it only after the user confirms the location; reuse an existing spec folder (for example `docs/specs/`) if there is one. One further file per requirement area is fine.
2. Build a stripped-down MVP straight from `specs/PRD.md` in one pass, before any full architecture or infrastructure.
3. Run the core loop. If it does not deliver the value the PRD claims, stop and tell the user: pivot or discard before investing more. The user decides.

## Audit procedure
1. List every file in `specs/`. Compute the change set to audit (`git diff <base>..HEAD` or the whole tree if no base). Ask the user for the base if unclear.
2. Spawn one read-only reviewer subagent (or fresh session, if no subagents) per requirement file, in parallel where possible. Each gets: that single file, the change set, and the instruction to return per-requirement status `implemented | partial | missing | contradicted`, with file:line evidence and a one-line reason. Reviewers read code only; they do not edit.
3. Meanwhile you (lead) audit the diff for **unrequested changes**: features, endpoints, UI, dependencies or behaviours that appear in no spec file. List each with file:line.
4. Merge results into the scorecard (format in the reference). Do not soften findings; a requirement without evidence is `missing`.
5. Present the report and ask the user, per divergence, to choose:
   - **Adopt**: update the spec file to include it, or
   - **Revert**: remove or rewrite the unaligned code.
   Make no spec edit and no revert before the user answers; confirm each revert that deletes code.
6. After applying the choices, re-run only the affected reviewers to confirm alignment.

## Rules
- Specs are the source of truth; code never silently redefines them.
- Reviewer subagents must not see each other's results (avoids anchoring).
- Unrequested does not mean wrong: it means undecided. The user decides.
- Report ambiguity in a spec as its own finding instead of guessing intent.

## References
- `references/scorecard.md`: load when writing the scorecard and reviewer briefs.
