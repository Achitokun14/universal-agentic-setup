---
name: harness2-deterministic-script-and-hook-guard
description: "Use when a task needs exact counts, totals, schema or pixel checks, or finishing must pass real checks."
---

# Deterministic scripts and completion gates

Never rely on reading and judging to count rows, add up line items, validate a file format or measure a layout. Write a short script, run it, report its output. And never declare a deliverable finished until it has been re-opened and checked.

## 1. Script offloading rule
Use a script when the answer is a count, a sum, a comparison, a schema check, a diff or a measurement.
- **Tables and money**: row counts, duplicate keys, missing keys, per-currency totals. Use integers (cents) or a decimal type, never floats, so totals are exact. Print the offending rows, not only a pass/fail.
- **Formats**: validate JSON/CSV against the expected columns and types before using the data.
- **UI against a reference image**: crop the same regions from reference and render, compare with an image library that is already installed (ask before installing one), and report the share of pixels within a tolerance. Take the tolerance and pass mark from the user's brief; a typical example is "at least 91% of pixels within 8/255 per channel", but that is an example, not a rule.
- Keep scripts to 20 to 40 lines, standard library where possible, one cross-platform interpreter (Python or Node), no network, read-only on user data (work on a copy), no deletion.
- **A checker that cannot fail proves nothing.** Run it once on a known-bad input (a duplicated row, a wrong total) and confirm it reports the failure before you trust a PASS from it.
- Run scripts only on files the user named. Show the script and its output in the report.

## 2. Completion gates (agent-side checklist)
Apply these three on every task of this kind, as steps you perform yourself:
1. **Step budget.** When about three quarters of the allowed steps or tokens are used while still reading or researching, stop gathering and start writing the deliverable from what you have; list what is still unknown.
2. **Deliverable gate.** Before saying "done", re-open the produced file (spreadsheet, PDF, HTML, code diff) and check with a script or the real tool: no formula errors (`#REF!`, `#DIV/0!`, `#VALUE!`, `#NAME?`), no unexpected blank cells, all tests pass with exit code 0. Quote the actual output.
3. **Contradiction halt.** If the specification contains two rules that cannot both hold, stop early, quote both rules and ask which wins. Do not spend a long deliberation silently picking one.

## 3. Hooks
Some agents can enforce these gates as runtime hooks. This skill does not create or edit hooks, settings, permissions or instruction files. If the user wants a hook, write the hook text in your reply (or in a scratch file the user names), explain what it runs, and let the user review and install it; a hook is code that runs automatically.

## Report
Which scripts ran, their exact output, the known-bad test result, which gates passed, anything left unchecked.

*Distilled from a third-party video summary of Google's Harness-squared research and two local-model demos (deterministic scripts, control-loop hooks). Method restated in own words; benchmark numbers dropped.*
