---
name: harness2-propose-probe-compose
description: "Use when an agent repeats a failure on one task type and each fix must be proven by side-by-side traces."
---

# Propose, probe, compose: evidence-gated harness improvement

Improve how an agent works on a recurring kind of task (its skills, scripts, checks, delegation, notes) by comparing real run traces, without an answer key and without growing the always-loaded instruction text. An edit is kept only when a side-by-side trace shows it removed an observed failure.

## 1. Where a fix belongs (do this before proposing anything)
Treat always-loaded instructions as scarce memory: they are paid for on every turn, and a rule added after one failure can hurt unrelated tasks. Route each lesson to the lightest place that works:

| Lesson is about | Put it in |
|---|---|
| a domain workflow or checklist | an on-demand skill |
| a repeated exact check (counts, totals, schema, pixels) | a small deterministic script (see the `harness2-deterministic-script-and-hook-guard` skill, if installed) |
| reading many or heavy files | an isolated subagent with a fresh context (or a fresh session) |
| a hard stop or completion condition | a check the user's own tooling enforces (describe it; the user installs it) |
| something true in every task and not inferable | one line in the instruction file, proposed to the user, never edited by you |

The editable surfaces are: system prompt, guardrails, memory, tool guidance, subagents, skills, scripts, hooks/plugins. Prefer the later ones over the earlier ones.

## 2. Stage 1 - PROPOSE
1. With the user's approval, pick one representative task and run it once with the current setup, in a scratch copy of the project. No pushes, deploys, sends or deletes. Capture the trace: commands and exit codes, tracebacks, repeated searches or reads, outputs that were never verified.
2. Diagnose the trace from two viewpoints, as two separate notes:
   - **Systems mechanics**: tool misuse, redundant reads, context bloat, missing isolation, endless research loops. Fixes: delegation, step limits, scripts.
   - **Domain specialist**: act as a domain expert (for example security auditor, data analyst, database engineer). Fixes: domain checklists, verification scripts.
3. Output a candidate list. Each candidate names the trace event it targets and the surface it edits. No candidate without a trace event.

## 3. Stage 2 - PROBE
1. Apply each candidate to its own copy of the harness files only (skill text, script, notes). Never edit the user's live skills, instruction files, settings or hooks.
2. Number of candidates K: 1 for a clear failure; 3 to 5 when the cause is unclear (cap at 5). Run them one after another, or in parallel only in separate working copies.
3. Re-run the exact same task input under baseline and each candidate and capture the traces. Ask the user before any run that is slow, billable or networked.

## 4. Stage 3 - COMPOSE
1. Compare traces by verifiable differences, not by how good the prose reads: did the new check catch a missing row, broken formula or failing test the baseline missed? Did a step limit stop a loop or timeout?
2. Keep only edits tied to a concrete trace-level fix. Discard the rest and say so.
3. **Judge is not the solver.** The agent that wrote a checker must not be the only one to grade it. Use a fresh-context reviewer (a different model family if you can choose) and test every self-written checker on a known-bad output: a checker that cannot fail proves nothing.
4. Give the evaluated run no access to grading material (answer keys, rubrics, hidden tests) and no open network where it is not needed; a run that can fetch its own rubric measures nothing.

## 5. Distill (second level)
After the kept edits work:
1. Remove everything specific to one case: client or project names, file paths, one-off ticket rules (a rule from one legal merger must not land in a database migration playbook).
2. Present the general items (skill text, scripts, stop conditions) to the user as a list. Write them to a library folder only after the user names the folder and approves; do not touch instruction files or hooks.

## 6. Cost and risk notes
- Evolution runs cost several times a normal run. Run it offline on a few past tasks (15 to 20 at most, as the source suggests), keep the result under version control, and use it in later normal runs; ask the user to approve the run count first.
- Never send proprietary code or secrets to a third-party model service without the user's approval.
- Source figures about accuracy gains come from a vendor-side video and paper summary and were not verified here; judge the result by your own traces.

## Report
Baseline failure, candidates, trace evidence per kept edit, discarded edits with reason, what was distilled, what the user must approve or install.

*Distilled from a third-party video summary of Google's Harness-squared research (propose, probe, compose; experience library). Method restated in own words; no upstream text copied.*
