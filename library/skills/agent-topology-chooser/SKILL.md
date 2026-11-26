---
name: agent-topology-chooser
description: "Use when choosing how to structure multi-agent or looped work: single agent, loop, router, fan-out"
---

# agent-topology-chooser

Pick the lightest agent structure that gives the verification the task needs. Everything is expressed with the agent's subagent feature (if available; one builder-type and one read-only reviewer-type subagent), a task list and plain project files. If the agent has no subagents, run the roles one after another in fresh sessions. Complements the `egm-dual-pass-review` skill (if installed; the full fresh-context review protocol) and any generic coordination skills; this skill only decides which shape to use.

## Rules

1. **Default to one agent.** Small or single-session work (one bug, one file, one short feature) stays in the main session. Orchestration overhead can cost more than doing the work alone; do not add subagents "for structure".
2. **Spawn subagents only for genuinely parallel work.** Independent slices with no shared file or ordering dependency. If step B needs step A's output, run them in sequence. State the reason for each spawn in the task description.
3. **Every topology needs a verification gate written before work starts** (a test, a score, a checklist, a fresh reviewer). No gate, no loop.
4. **Judge nodes must not run on a weaker tier than the work they judge.** A weak reviewer produces false positives that poison everything downstream. If you cannot choose the model tier, tell the user and have judges at least match the builders.
5. **Workers get self-contained tasks**: files, acceptance checks, constraints, what to return. They do not see this conversation.
6. **Isolate parallel writers**: separate files or separate checkouts (separate worktrees or copies of the folder); never two writers on the same path.
7. **Outward or irreversible actions** (push, deploy, publish, delete, send) are never delegated to loops or workers without explicit user confirmation.
8. Cap loops: a maximum iteration count and a stop condition (all gates pass, or no measurable progress for N rounds -> stop and report).

## Decision table

| Topology | Best fit | Verification gate | Guardrail |
|---|---|---|---|
| Single agent | small or one-shot work | your own checks run | no subagents |
| Checks-first improvement loop | repeated feature builds or measurable optimisation with an automated score and a runnable environment | checks written first and kept read-only to the builder (committed before the loop starts) | after each iteration record results and lessons in a notes file the next fresh builder reads, so mistakes are not repeated |
| Gated multi-stage loop | large multi-screen rebuilds needing strict behaviour and UI parity | sequential gates: behaviour tests -> visual prototype check -> adversarial critic and fixer rounds -> human review | do not leave a stage until its gate passes; the user is the last gate |
| Ticket router with isolated workers | 5-20 parallel feature tickets in one project | per-ticket requirements file plus eval file written before work; a checker agent per ticket; a merger | the router coordinates and never writes code; each worker has its own checkout |
| Asymmetric memory-planner + fresh reviewer | high-stakes design where flaws or concurrency bugs are costly to fix later | several zero-context reviewers over the plan, then a drift check of the built result against the plan | not for small one-shot fixes; use `egm-dual-pass-review` |
| Diamond / barrier fan-out | parallel multi-module generation, or audits from several lenses at once | fan out to independent workers, wait at a barrier, then one synthesis and one verification node | judges run on a tier not weaker than the builders; synthesis reads outputs rather than trusting summaries |

## Procedure
1. Describe the task in one line plus its failure cost and whether slices are independent.
2. Walk the table top to bottom; stop at the first row that fits.
3. Write the gate and the stop condition in the plan before the first spawn.
4. Report the chosen topology and why simpler ones were rejected.

## References
None; the table is the whole guide. Details of the reviewer protocol: the `egm-dual-pass-review` skill (if installed).

*Distilled from a strategy compendium of third-party summaries (loop/graph matrix and conductor rule; no license; method restated in own words).*
