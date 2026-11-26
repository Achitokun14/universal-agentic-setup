---
name: invariant-tests-gate
description: "Use when starting a feature whose non-negotiable product rules need user-approved tests first."
---

# Invariant tests gate

Prose rules in an instruction file fade from a long context; committed tests do not. Every invariant gets a test, authored before the feature code, approved by the user, and not weakened by the builder.

## Procedure
1. **Invariants.** Propose a `## Must Not Trade Off` section for the project's instruction file (latency, security, correctness, data-safety rules). Show it to the user and let them add it; do not edit the instruction file yourself unless the user asks you to.
2. **Checks first.** For each invariant, and for each planned feature, write binary pass/fail tests before any feature code. Each test fails now for the right reason (run it to confirm).
3. **Approval.** Present the tests (file list plus what each asserts). Wait for explicit user approval, then commit them only if the user asks. Record the approved file list.
4. **Build.** Implement against the tests. The builder may add tests; it may not delete, skip, loosen or rewrite approved ones. If a test seems wrong, stop and ask the user.
5. **Done means green.** A feature is not complete while any approved test fails; show the actual run output.
6. **Protect the tests.** Do not try to lock files by changing agent settings, permissions or hooks. Tell the user what they can do: mark the folder read-only, add a CODEOWNERS/branch rule, or review any diff touching the approved paths.

## Learning from the log (optional loop)
- With the user's agreement to create the file, append each attempt to a `results.md` in the project: feature, outcome, failure reason.
- After each feature, scan it for repeated mistakes (e.g. schema built but form not wired; logic updated in one view but not the legacy copy).
- Write **proposals** for the project's working notes ("How to work") as a list with the evidence, and show them to the user. Never rewrite the notes or the approved tests automatically.

## Rules
- Each invariant maps to at least one named test; list the mapping in the report.
- No invariant without a test; no test weakened without user consent.
- Tests must be deterministic and runnable headless.

## References
- `references/templates.md`: load when drafting the invariant section or results log.
