---
name: engineering-workflow
description: "Use when implementing, fixing or refactoring code: TDD, root-cause debugging, verify-before-done, commit/PR."
---

The engineering loop for code changes: plan -> test first -> debug on failure -> verify -> handle review feedback -> commit/PR. Evidence before claims; root cause before fixes; user confirmation before anything leaves the machine.

## Pick the tier

Match ceremony to blast radius. If unsure, start LOW and escalate the moment a surprise appears (second failed fix, test that cannot be written, unclear behavior).

**LOW - quick fix** (typo, one-function bug, config tweak, <~30 lines, single file):
1. Write ONE failing test (or a one-line repro command) that shows the symptom; run it, see it fail for the right reason.
2. Minimal fix; rerun that test; then the project's own check command (below).
3. Report the exact command and its result. No other ceremony.

**MEDIUM - full loop** (feature, multi-file bug, refactor with behavior):
1. Restate the goal and the seams (public interfaces) you will test at; ask only if a seam is truly ambiguous.
2. Vertical slices: one failing test -> minimal code -> green -> next slice (`references/tdd.md`).
3. Failure you do not understand -> stop, diagnose with a tight feedback loop (`references/debugging.md`).
4. Simplify pass, then full verification gate (`references/verification.md`, `references/quality-passes.md`).
5. Commit locally in logical commits (`references/git-pr.md`); stop and ask before push/PR.

**HIGH - risky change** (auth, money, data migrations, parsers/serializers, concurrency, dependency major bump, public API):
Everything in MEDIUM plus:
- Property-based tests for round-trips, invariants, oracles (`references/property-tests.md`).
- Adversarial review through fresh-context subagents, or a fresh session if the agent has no subagents (`references/adversarial-review.md`; attack categories for the breaker brief: `references/adversarial-breaker-matrix.md`).
- Dependency upgrades follow the playbook in `references/dependency-upgrade.md`.
- Production-readiness pass and a written rollback path (`references/quality-passes.md`).
- Record non-obvious lessons (`references/learnings.md`).

## Verification commands

Prefer the repo's own scripts (`package.json` scripts, `justfile`/`Makefile`, CI workflow). Detect, then run:

| Stack | Test | Static checks |
|---|---|---|
| Python (uv) | `uv run pytest -x -q` | `uv run ruff check .` ; `uv run ruff format --check .` ; `uv run ty check` |
| Node (pnpm) | `pnpm test` | `pnpm run lint` ; `pnpm exec tsc --noEmit` ; `pnpm run build` |
| Bun | `bun test` | `bun run lint` ; `bunx tsc --noEmit` |
| Go | `go test ./...` | `go vet ./...` |
| Rust | `cargo test` | `cargo clippy -- -D warnings` ; `cargo fmt --check` |

Machine limits: on a small machine (few cores, little free RAM) run one heavy suite at a time, do not parallelize builds across subagents, cap workers (`pytest -n 2`, `cargo test -j 2`, `pnpm test -- --maxWorkers=2` where supported). On Windows use PowerShell or forward-slash paths; Git Bash can mangle Windows paths. Never print secrets; pass them to commands as environment variables from your secret manager.

## The loop

1. **Plan** - Read the code and nearby tests first (code search / language-server features if available, not guessing). Name the behavior change, the seams, and the verify command. Check for `GLOSSARY.md`/ADRs in the area. Scope is the ask, nothing more.
2. **Test first** - Red before green. Watch the test fail for the *expected* reason (feature missing, not typo/import error). Expected values come from an independent source (literal, spec), never recomputed like the code does.
3. **Implement** - Minimal code to pass; no speculative options. Refactor only on green and only behavior-preserving.
4. **On any failure** - Do not guess-fix. Build a tight red-capable loop, reproduce, minimise, hypothesise with predictions, change one variable at a time. Three failed fixes = question the design, discuss with the user.
5. **Verify** - Run the full project gate fresh (not just your new test), read the output and exit code, then report claims with that evidence. A red test you saw and did not mention is a false report.
6. **Review feedback** - Verify each comment against the code before implementing; push back with technical reasoning when wrong; one item at a time (`references/review-feedback.md`).
7. **Commit/PR** - Stage named files only, audit the staged diff, let the repo's pre-commit hooks (for example lefthook) run, commit locally. **Never push, open a PR, merge, or post review replies without explicit user confirmation for that exact action.**

## Rules

- No production code without a failing test first; for throwaway prototypes, generated code, or config, say you are skipping and why.
- Test behavior through public interfaces. Mock only at system boundaries (network, clock, randomness, filesystem when needed), never your own modules. Tests that break on refactor without behavior change are wrong tests.
- Never claim "fixed", "passes", "done", "should work" without a command run in this turn whose output you read. Agent/subagent reports are claims, verify via `git diff` and rerun.
- Fix at the source of bad data, not where the error surfaces; then add validation at the layers it passed through.
- Never weaken, skip, delete, or loosen a test to get green. Never `--no-verify` or bypass the repo's hooks unless the user asks.
- One logical change per commit; no unrelated cleanups ("while I'm here"); preserve unrelated staged/unstaged work.
- Redact secrets in everything shown, logged, or committed; scan the staged diff before every commit.
- Remove debug instrumentation (tag every probe `[DEBUG-xxxx]` so one grep finds them) and throwaway scripts before finishing.
- Existing code style, tooling, and package manager win over personal preference; do not migrate tooling unasked.
- Stop and ask when: requirements are ambiguous in a way tests cannot settle, a fix needs a public API/contract change, a destructive or irreversible step is next, or the root cause cannot be confirmed.

## Routing table

| Situation | Load |
|---|---|
| Writing/choosing tests, mocks, seams, regression test | `references/tdd.md` |
| Parsers, codecs, serializers, normalizers, invariants, numeric code | `references/property-tests.md` |
| Bug, failing/flaky test, build failure, perf regression | `references/debugging.md` then `references/debugging-techniques.md` |
| About to say "done", pre-commit/pre-PR gate | `references/verification.md` |
| Simplify, error handling, self-review, ship-readiness | `references/quality-passes.md` |
| Review comments received (PR or user) | `references/review-feedback.md` |
| Independent fresh-eyes review of a diff (HIGH) | `references/adversarial-review.md` |
| Stress-testing a built feature with a hostile breaker (races, double submit, bad input) | `references/adversarial-breaker-matrix.md` |
| Commit, branch finish, PR body | `references/git-pr.md` |
| lefthook setup, merge conflict, rebase, git recovery | `references/git-hooks-history.md` |
| Major dependency bump, vuln fix by upgrade | `references/dependency-upgrade.md` |
| Python project, script, pyproject, uv, ruff, pytest setup | `references/python-uv.md` |
| Non-obvious problem solved, worth recording for next time | `references/learnings.md` |

## References

- `references/tdd.md` - load when writing or reviewing tests, deciding seams/mocks.
- `references/property-tests.md` - load when code has an inverse/invariant/oracle (HIGH).
- `references/debugging.md` - load when anything fails and the cause is not obvious.
- `references/debugging-techniques.md` - load when tracing deep errors, flaky/timing tests, or 3 fixes have failed.
- `references/verification.md` - load before any completion claim or commit.
- `references/quality-passes.md` - load for simplify/error-handling/self-review/readiness passes.
- `references/review-feedback.md` - load when processing review comments.
- `references/adversarial-review.md` - load for HIGH-tier independent review via fresh-context subagents.
- `references/adversarial-breaker-matrix.md` - load when writing a breaker brief: attack categories, procedure, round cap.
- `references/git-pr.md` - load for commits, branch finish, PR text.
- `references/git-hooks-history.md` - load for lefthook pre-commit, merge conflicts, history repair.
- `references/dependency-upgrade.md` - load for major/security dependency upgrades.
- `references/python-uv.md` - load for any Python tooling work.
- `references/learnings.md` - load after solving something non-obvious.

Planning, specs, and ADRs belong to the `plan-and-design` skill; executing multi-step plans uses the agent's todo list and subagents, if available.

Provenance: see `SOURCES.md`.
