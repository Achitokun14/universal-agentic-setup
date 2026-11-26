---
name: outcome-prompting
description: "Use to rewrite a task prompt as an outcome goal with depth and range, before delegating a build or audit"
---

# Outcome prompting: altitude, depth, range

Rewrite a task so the agent aims at the outcome rather than a widget list, works with expert method and real evidence, and gets audited from several unrelated disciplines. Advisory: produce the rewritten prompt and, if the user asks, run it.

Different from prompt-optimizer-style skills (component matching and context gaps) and interview-style skills (questioning the user): this changes the shape of the goal.

## Three moves

1. **Altitude.** State the business or user outcome, not the parts. "Make the app crash-free" beats "add try/catch to these handlers"; "a hiring dashboard that shows where candidates stall so we hire faster" beats "bar chart, table, filters". Keep hard constraints (stack, files off limits, deadlines) as constraints, not as the goal.
2. **Depth.** Ask for domain-expert method rather than a role tone: name the methods a specialist would actually use, require real data or the real running app as evidence, and require independent verification (a different reviewer, a measurement, a test), not the author's own say-so. Pair it with one deliberately unreasonable target ("loads instantly") so the agent hunts for the real limit and reports how far it got and what blocks the rest.
3. **Range.** Replace nouns with verbs ("get strangers to trust us with their next job" rather than "build a testimonials section"). Then run specialists from unrelated fields one after another (for example a security reviewer, an accessibility reviewer, a conversion copywriter, a performance engineer), each auditing the result and fixing or listing findings before the next starts.

## Procedure

1. Restate the user's request as one outcome sentence and a measurable done condition; confirm it if the request is ambiguous.
2. Rewrite the prompt with: outcome, constraints, expert methods to use, evidence required, the stretch target, and the specialist sequence.
3. Add the cross-review: after the build, a fresh-context read-only subagent or session (if available) checks the result against the done condition without seeing the build history. If the user has a second model available, offer it for this check as an option.
4. Show the rewritten prompt; run it only when the user asks. Anything outward (deploy, publish, send) still needs their confirmation.

## Never

- Drop the user's explicit constraints in the name of "higher altitude".
- Use the stretch target as an excuse to ship something unsafe or untested.
- Claim an outcome met without a measurement or a check you ran.

Distilled from compendium notes on a prompting skill organized as altitude, depth and range; only the stated rules are used. Own words.
