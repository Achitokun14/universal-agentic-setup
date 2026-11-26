---
name: journey-completion-report
description: "Use before a release to run scripted browser journeys on critical paths and report pass/fail and latency."
---

# Journey completion report

Measure "error-free sessions": the share of core end-to-end journeys that finish without an error or a slowdown.

## Procedure
1. List critical journeys with the user (signup, login, core action, checkout, ...). Each is an ordered list of steps with an expected visible result and a latency budget in ms; ask the user for budgets if none exist.
2. Run only against a local, staging or test environment. Production, real payments and real accounts need explicit user confirmation and test credentials supplied by the user.
3. Drive each journey with the agent's browser automation (a browser tool, Playwright-style script or Chrome DevTools MCP; headless is fine) on a dedicated test profile. For every step record: name, pass/fail, elapsed ms, error text or console error, screenshot path when failing.
4. Write results to `reports/journeys.json` in the project (schema in the reference). Compute `error_free_rate = journeys with all steps passed and within budget / total journeys`.
5. For each failing or slow step, find the root cause; auto-fix only small, well-understood defects with a regression test, list the rest under "Decisions for a human", then rerun that journey. Show the user the code changes; do not mask failures by loosening budgets or expected results.
6. Repeat until all journeys pass or the user accepts known gaps; keep the final JSON plus the previous run for comparison.

## Rules
- A journey passes only if every step passes within budget.
- Use fresh state per journey (new test user, clean data) so runs are repeatable.
- Never include secrets or personal data in the JSON.
- Ask before creating a new `reports/` directory in the project.
- Do not deploy or push the fixes without user confirmation.

## References
- `references/report-schema.md`: load when writing the JSON report.
