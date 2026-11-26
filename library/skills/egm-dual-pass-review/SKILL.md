---
name: egm-dual-pass-review
description: "Use after a non-trivial code change or design draft to get an independent fresh-context subagent review"
---

# egm-dual-pass-review

Two roles, two contexts. The builder ("elephant") keeps all project context and persistent notes. A reviewer ("goldfish") is a fresh, read-only subagent (or a fresh agent session) that sees only the artifact and evidence, so it cannot inherit the builder's assumptions. The user decides trade-offs and approves.

Complements the `engineering-workflow` skill (TDD, verify, commit) and the `security-review` skill (vulnerability audit), if installed; this skill adds the isolation protocol and lens set. Not for one-line edits or typo fixes.

## Rules

1. **Builder keeps notes.** Before coding, write a short working file (e.g. `notes/<task>.md` outside versioned docs unless the user wants it): goal, baseline commit, checklist, decisions with reasons, items marked `UNVERIFIED`, and `CONTEST` rationales already accepted. Update at each checkpoint. Notes are builder memory only; never pass them to the reviewer.
2. **Reviewer input is evidence, not narrative.** Give the subagent exactly: (a) the diff against the recorded baseline, including deleted files and the full content of new untracked files (never `.env` or other secret files; redact credentials); (b) the real test/lint/typecheck output you ran, verbatim; (c) the task goal in one or two neutral sentences; (d) for design docs, the document path and the source files it cites. Omit conversation history, your justifications, and earlier reviewer findings.
3. **Fresh context is mandatory.** Start a new subagent (or fresh session) per review pass; never resume one. If neither a subagent feature nor a fresh session is available, say so and stop: a same-context self-review is not this protocol.
4. **Read-only reviewer.** State in the task that it must not edit files, run installs, or touch the network. It reports findings only.
5. **Incomplete coverage stops the review.** If any part of the diff, baseline, or cited file cannot be inspected, report incomplete coverage rather than asking for approval.
6. **Pick lenses by artifact** (see `references/lenses.md`). Code diff: use correctness/boundaries, test audit, zoom-out (YAGNI/reuse), plus design critic for non-trivial architecture. Design doc: structural, style, comprehension, design critic, implementation readiness, zoom-out. Run independent lenses as parallel subagents, one per lens.
7. **Binary verdict contract.** Each reviewer returns either findings only, or exactly `LGTM` with zero findings, never both. Each finding has severity (Blocker, Major, Nit), file and line range, and rationale with a recommendation.
8. **Failed reviewer is not a clean reviewer.** A timeout, crash, or empty reply means `not run`. Retry once; if it fails again, record `not run` in the report. Never count it as zero findings.
9. **Builder triages, user decides.** Verify each finding against the code or spec yourself. Sort into `PROPOSE FIX` (verified defect, with a concrete patch idea) and `CONTEST` (false alarm or misunderstanding, with evidence). Number them, tag priority P0 blocker, P1 defect, P2 polish, P3 nit. Present both groups and let the user override any classification before you edit anything.
10. **Record accepted CONTESTs** in the notes so a later pass does not re-raise them; tell the next reviewer to skip them only if the user approved that wording.
11. **Re-review after fixes** with a new subagent and the updated diff. Loop until `LGTM` or the user accepts the remaining findings.
12. **Review does not replace tests.** Reviewer output is evidence, not a pass. Run the project's checks yourself and quote results.

## Reviewer task template

Use this shape (fill the brackets; no builder reasoning):

```text
You are an independent reviewer with no project history. Read-only: do not edit files.
Lens: [lens name and its questions from the lens reference]
Goal: [1-2 neutral sentences]
Diff: [diff or path to saved diff file]
Verification output: [verbatim command output]
Report: findings only, each with severity, file:lines, rationale, recommendation.
If and only if there are zero findings, reply exactly: LGTM
Do not re-flag: [user-approved exclusions, or "none"]
```

## References

- `references/lenses.md`: load when choosing reviewer lenses or writing a lens-specific task prompt.
- `references/report-format.md`: load when aggregating several reviewer outputs into one report.
