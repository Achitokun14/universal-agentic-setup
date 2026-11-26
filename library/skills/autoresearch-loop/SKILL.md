---
name: autoresearch-loop
description: "Use for metric-driven iteration: bounded modify, verify, keep/discard loops (optimize, fix-until-green, benchmark, eval-harness)."
---

# Autoresearch loop: modify -> verify -> keep/discard against a metric

A bounded, logged improvement loop. One change per iteration, a mechanical verify command decides, losers are reverted. Plain steps only: no scripts, hooks, webhooks or orchestrators are needed or allowed.

## Set-up (ask first; do not start until answered)

Ask the user for, or derive and confirm:
1. **Goal + Scope**: files the loop may edit (mutable) and files it must not touch (tests, fixtures, harness, benchmark data).
2. **Metric**: one number (or pass/fail) and direction (lower/higher), e.g. test failures, p95 ms, bundle KB, val loss, eval score.
3. **Verify command**: exact shell command that prints/derives the metric (repeatable, <= a few minutes). Run it once now = baseline; if it cannot run, stop and say why.
4. **Guard** (must stay green every iteration): e.g. full test suite, type check, lint, build. A candidate that improves the metric but fails the guard is discarded.
5. **Budget**: `N` iterations (default 15, max 25 unless user raises it), optional wall-clock/cost cap, plateau stop (default: 5 consecutive non-improvements).
6. **Git permission**: may the loop create a scratch branch and commit kept changes? (default: no commits; stage only). Never push, open PRs, publish or deploy without a separate explicit approval.

Refuse unbounded runs ("until it's perfect"): offer a larger N instead. `Iterations: unlimited` only if the user says it explicitly, and still keep the plateau stop.

## Pick the tier / mode

- **LOW** - single mode, serial, in-session, no extra tools. Use for fix-until-green, small optimize tasks, <= 10 iterations.
- **MEDIUM** - add noise handling and a held-out check: repeat measurement 3x and use the median for noisy metrics (benchmarks), accept only if the gain exceeds the observed spread; confirm the final winner against the baseline again; keep a hypothesis table (see below). For hyperparameter/benchmark loops persist every run to the ledger.
- **HIGH** - parallel variants: spawn subagents (if the agent supports them; otherwise run variants one after another), each in its own isolated worktree/branch (`git worktree add ../ar-<run>-<k> -b autoresearch/<run>-<k>`), each testing ONE hypothesis against the same verify command; the parent collects metrics, keeps the best (and a file-disjoint runner-up if it still helps when combined and re-measured), removes worktrees. Cap concurrency to the machine (check cores and free RAM first; leave headroom for the user, e.g. at most half the cores and no variant that needs more than its share of free RAM). Details: `references/parallel-and-optimize.md`.

Modes (all share the loop):
- **optimize** - improve a metric (speed, size, score). Needs baseline, correctness guard, budget; see `references/parallel-and-optimize.md`.
- **fix-until-green** - metric = number of failing checks (tests/lint/type errors); target 0; fix one root cause per iteration; default 20 iterations.
- **benchmark** - metric = measured latency/throughput/cost; variants differ by one hypothesis each; same input shape each run; promote only a repeated, correct win.
- **eval-harness** - metric = pass@k on defined capability/regression evals for prompts/agents; define evals before changing anything; see `references/eval-harness.md`.

## The loop (plain steps)

Run directory: `autoresearch/<run>/` where `<run>` = `<mode>-<yymmdd>-<hhmm>`; log file `autoresearch/<run>/results.tsv` with the header
`iter<TAB>commit_or_snapshot<TAB>metric<TAB>guard<TAB>status<TAB>description` (status = baseline | keep | discard | crash). Add `autoresearch/` to `.git/info/exclude` so the log is not committed.

0. Preconditions: working tree clean for the mutable scope (`git status --porcelain`); if dirty, ask. If commits are allowed: `git switch -c autoresearch/<run>` (scratch branch). Never work on the default branch.
1. Baseline: run the verify command, record `iter 0 ... baseline`.
2. Review: `git log --oneline -10`, `results.tsv` tail, the last diffs. What worked, what failed, what is untried? Do not repeat a discarded idea.
3. Hypothesis: pick ONE focused change with a reason tied to evidence (profile, error output, failing test). Write it as the description before editing.
4. Edit only mutable scope. Keep the diff small and note exactly which files were touched (the revert list).
5. Verify: run the verify command, then the guard. Timeout/crash -> status `crash`.
6. Decide mechanically:
   - metric strictly better than the current best (beyond noise at MEDIUM+) AND guard passes -> **keep**: commit if allowed (`git add <files>; git commit -m "autoresearch(<run>): <description>"`), else just `git add <files>` (staging is the snapshot); the new best is this metric.
   - otherwise (worse, equal, guard failed, crash) -> **discard**: `git checkout -- <touched files>` (restores the last kept state: HEAD, or the index if changes are only staged); delete files this iteration newly created (`git clean -f -- <those paths>` only). Never `git reset --hard`, never touch files outside the revert list.
   - simpler code with equal metric counts as a keep (simplicity wins ties); a tiny gain with ugly complexity is a discard.
7. Append the row to `results.tsv` (tabs; description without tabs). Print one line: `iter N | metric | keep/discard | description`.
8. Stop when: target reached, N iterations done, plateau (5 consecutive discards), budget hit, 3 crashes in a row, or the user interrupts. Otherwise go to 2.
9. Wrap-up: re-run verify + guard on the final state, report baseline -> best, kept/discarded/crash counts, the `results.tsv` path and branch name, and the remaining untried ideas. Offer next steps (merge, PR, push) as options; do nothing until the user says so.

#### macOS / Linux (bash)

Create the folder with `mkdir -p autoresearch/<run>`; append a row with `printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$i" "$sha" "$metric" "$guard" "$status" "$desc" >> autoresearch/<run>/results.tsv`.

#### Windows (PowerShell)

Use forward-slash paths and the `git` commands exactly as above; append with `Add-Content -Path autoresearch/<run>/results.tsv -Value "$i`t$sha`t$metric`t$guard`t$status`t$desc"`; create the folder with `New-Item -ItemType Directory -Force autoresearch/<run>`.

## Rules

- Mechanical verify decides, not opinion; if the metric is subjective, define a rubric/eval first (`references/eval-harness.md`).
- One change per iteration, so cause and effect stay attributable. Never edit the verify command, guard, tests or fixtures to make a metric look better (reward hacking); if the harness is wrong, stop and tell the user.
- Read before writing: check prior results and the current code each iteration; context resets must not repeat past mistakes (the TSV is memory).
- After repeated failure, change strategy (different category, bigger refactor, revisit assumptions) instead of micro-variants; after plateau, stop and report rather than burn iterations.
- Do not add dependencies, change infra/CI, or touch secrets/credentials inside the loop without asking.
- Security/data safety: loops never run against production data or remote services; verify commands run locally. Destructive commands are not part of a loop.
- Do not push, publish, deploy, send messages or open PRs. No `orchestrate.sh`, no hooks, no stop-notify webhook, no `claude -p` loops, no pipe-to-shell installers.
- Report numbers from the log, never from memory; say "best measured safe variant", not "optimal".

## References

- `references/parallel-and-optimize.md` - load for HIGH tier, hypothesis backlog, noise/plateau rules, benchmark promotion gate.
- `references/eval-harness.md` - load for eval-driven work: capability/regression evals, graders, pass@k, report format.
- `references/loop-patterns.md` - load to choose a multi-step pipeline (sequential, de-sloppify, shared notes, DAG) and avoid loop anti-patterns.
