---
name: workflow-automation-audit
description: "Use before automating a human operator's workflow with an agent, to audit the real process first"
---

# workflow-automation-audit

Audit a human process before any agent touches it. Generic tools laid over an unmapped workflow fail because the real rules live in the operator's head. The output is an audit document plus a go/no-go, not code.

Complements the `plan-and-design` skill (specs, tickets, ADRs for a build you already decided on) and product-lens-style skills (is the product worth building), if installed. Auditing automations that already run is a different job; this skill audits a manual process that is not yet automated.

## Rules

1. **Pick by volume.** Choose the workflow to audit from real records (ticket exports, logs, queue history, with the owner's permission): the task repeated most often wins. Write the measured frequency in the audit; if no records exist, say the frequency is an estimate.
2. **Shadow the operator.** Watch one or more operators do the job (or read a recorded walkthrough they provide). Log every action in order. For each step ask "why?" and write the answer next to it. Mark each answer `documented` (found in policy) or `undocumented` (tribal rule). Undocumented rules are the main finding; list them first.
3. **Do not log or share personal or customer data** while shadowing. Use redacted examples; ask the user before reading any record that holds personal data.
4. **Partition every step** with the three filters in `references/partition-and-controls.md`: deterministic rule -> plain code; unstructured judgment -> model; high cost of failure -> human approval or fully human. A step can be in more than one filter; the strictest wins. Record the result per step in the audit table.
5. **Keep familiar steps visible.** Automate the labor inside each step, but keep the operator's existing checkpoints and intermediate outputs viewable. Do not collapse a multi-step verification into one opaque action unless the operators agree to it.
6. **Work inside the incumbent tools** the team already uses. Propose a new destination app only if the user asks for one; never plan a forced migration.
7. **Design for uncertainty** per step: a numeric confidence threshold below which the agent stops, an escalation path naming who or which queue receives the case, and an exception handler for each failure mode seen in the shadow log and in the historical cases. A model answer with no stated uncertainty handling is not acceptable.
8. **Backtest before live use.** Run the proposed pipeline offline on an exported or user-approved local/test copy of historical cases (never against a production database or live queue) whose correct outcome is known. Report accuracy per step and per case type, cluster the failures, fix the clusters, rerun. Go live only after the user reviews the backtest and approves; first live use runs in shadow or review-all mode.
9. **Quantify net value** in exactly three terms: revenue added, cost removed, risk avoided, each with the assumption behind it. Subtract running cost and the cost of wrong decisions. If the net is not clearly positive, the verdict is "do not automate" or "automate fewer steps".
10. **Budget trust time.** The plan must allot pilot and operator-trust time, typically a multiple of the engineering time, and say so in the schedule. Name who signs off at the end of the pilot.
11. **Evidence over claims.** Do not cite adoption rates, studies or vendor claims as justification; use only the team's own measurements.
12. Any step that changes data, sends messages, or acts outside the user's systems needs explicit user confirmation before it is built or run.

## Audit output

Write one file (for example `workflow-audit/<process>.md`) with: process and measured volume; step table (step, operator action, why, documented/undocumented, filter result); undocumented-rule list; per-step threshold, escalation and exception handlers; backtest plan and results; net-value table; pilot and sign-off plan; verdict (go, go-reduced, no-go) with reasons.

## References

- `references/partition-and-controls.md`: load when applying the three-way filter, setting thresholds, or writing the backtest and value sections.
