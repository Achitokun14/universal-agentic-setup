---
name: unlazy-parallel
description: "Use for large multi-requirement builds where agents drop items or self-certify: task tree plus ledger."
---

# Unlazy: task tree and evidence ledger

Agents given a flat requirements list tend to satisfy most items, stop early and report 100%. Two fixes: split the work into a tree whose leaves are real work, and require every leaf to be proven by a command whose actual output is written into a ledger, never by the agent's own tick.

## 1. Depth-N decomposition
- Default depth 3; use 2 for a narrow feature, 4 or more for a whole system. Ask the user if unsure.
- Each leaf is at least about 10 minutes of real engineering work. Stop splitting a branch when the children would be trivial steps.
- Execution: depth 3 or less - group leaves that touch disjoint files and run them in parallel (subagents if available; the number the machine and agent can run reliably, the source used up to 10; otherwise run them in order). Depth 4 or more - you coordinate only: hand isolated branches to workers and audit their ledger evidence.

## 2. Ownership plan (`plan.md`)
Propose a folder (default `.unlazy/` in the project root) and create it only after the user agrees. Before any worker starts, write `plan.md`: every leaf ID (`T1.1.1`, `T1.1.2`...), and for each the files it may write. One leaf holds the write lock on a path at a time; others may read it. Parallel writers use separate files or separate checkouts. For one self-contained brief per parallel session, use `references/subtask-manifest.md`.

## 3. Verification ledger (`gates.md`)
Write the ledger before coding. One gate per leaf, in exactly this shape:

- [ ] **Gate ID - requirement summary**
  - `Command`: the exact test, script, request or browser step
  - `Expected Output`: a literal substring, or exit code 0
  - `Evidence`: `PENDING`

Commands must be non-destructive and local or against a test environment: no production, no deletion outside test fixtures, no spending, no messages sent. **Show the ledger to the user and get approval before the first run**, because running it executes the commands.

## 4. Zero self-grading
- Run each `Command` yourself in a real shell (or let the user's CI run it) and paste the real stdout, stderr and exit code into `Evidence`. Tick `[x]` only when that evidence matches `Expected Output`.
- A tick with `Evidence: PENDING`, or evidence you typed rather than captured, is invalid: untick it and say so.
- After 3 failed repair attempts on a gate, stop. Write `GAVE UP: <root cause and blocker>` in `Evidence` for the user. Never fake a pass.
- A parent leaf is done only when all its children pass; the build is done only when every gate passes. Report the count of passed, failed and given-up gates.

## 5. Limits
- Do not run installers, deploys, pushes or deletions as part of a gate.
- Judges and worker audits run at a tier not weaker than the workers.
- The skills `agent-topology-chooser` and `invariant-tests-gate` (if installed) decide when this much structure is worth it; small tasks do not need it.

*Distilled from a third-party video summary of an anti-laziness skill, adapted for parallel leaf tasks, and from a second summary on handoff manifests. Method restated in own words.*
