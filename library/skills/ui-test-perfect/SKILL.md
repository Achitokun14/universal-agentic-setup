---
name: ui-test-perfect
description: "Use to run, repair or harden web-app E2E/UI/functional tests with Playwright/Cypress, optional UI-TARS visual checks and firecrawl references; needs the repo path and a running URL."
---

# ui-test-perfect

Perfect an app's E2E / UI-UX / functional tests by layering three capabilities. Each layer degrades gracefully: run the layers whose prerequisites are met, and tell the user exactly which prerequisite is missing for any layer you skip. NEVER fabricate a passing result for a layer you could not run.

## Inputs (ask once, do not guess)
- `repo` — path to the app's source.
- `url` — the running app URL (e.g. `http://localhost:3000`). If the app is not running, find its dev command in `package.json` and start it, or ask.
- `framework` — `playwright` | `cypress` | `none`.

## Layer 1 — Local code reading + deterministic E2E (no API key required; always available)
1. Read `repo`: detect the test framework (look for `playwright.config.*`, `cypress.config.*`, `e2e/`, `tests/`), package scripts, and the app's routes/components under test.
2. If `framework: none`, ask the user, then scaffold Playwright: `npm i -D @playwright/test && npx playwright install` (large browser download) and generate a minimal smoke spec covering the primary user flows you found in code.
3. Run the suite (`npx playwright test` / `npx cypress run`). Capture failures with stack traces, failing selectors, and screenshots.
4. Triage each failure against the source: is it a flaky selector, a real regression, a timing issue, or a broken feature? Propose the fix at the source, apply it, and re-run until green or until a failure needs human judgment.

## Layer 2 — UI-TARS visual / UX exploration (requires a model endpoint)
Uses the `agent-tars` CLI (verify: `agent-tars --version`). If it is missing, tell the user and ask before installing anything; follow the tool's own documented install and pin the version.
- Prerequisite: a model endpoint. Configure one through the CLI options (`agent-tars --help` lists them): provider, model id, base URL and API key. Ask the user which provider and key to use; the key comes from the user's environment or secret manager (for example `$MODEL_API_KEY`). Never paste keys into commands, files or chat.
  - Example shape: `agent-tars --model.provider <provider> --model.id <model> --model.baseURL <endpoint-url>`; supply the key through the tool's config file or environment mechanism (for example `apiKey` read from `MODEL_API_KEY`) so the value never appears on the command line (argv is visible in process listings). Do not pass `--model.apiKey` with a literal or expanded secret.
  - Caveat seen in agent-tars 0.3.0: the `anthropic` provider ignores `--model.baseURL`; for anthropic-compatible third-party endpoints use `--model.provider openai` with their openai-compatible URL.
  - Browser control in DOM mode (`browser.control: dom`) needs no vision grounding; switch to `hybrid` only with a true vision-language model.
- Using a hosted model endpoint sends page content and screenshots to that provider: tell the user and get a go-ahead before the first run.
- Use it for what deterministic tests miss: visual regressions, layout/contrast/responsive issues, confusing flows, and exploratory "does this actually feel right" UX passes against `url`.
- Feed its findings back into Layer 1 as new assertions/specs so regressions become deterministic going forward.
- If no endpoint is configured, SKIP this layer and state: "Layer 2 (UI-TARS visual) skipped — no model endpoint configured."

## Layer 3 — firecrawl web reference (optional; requires `FIRECRAWL_API_KEY`)
Only for pulling external reference data (e.g. comparing against a live competitor page, or fetching spec/docs the tests assert against). firecrawl is NOT a test driver — do not use it to exercise the app. It is a third-party service: URLs you send leave the machine, so ask the user first. If no key, skip and say so. For scraping tiers and fallbacks see the `web-ui-toolkit` skill (if installed).

## One-time setup the user must do (do NOT stub these)
- Model endpoint: the user supplies the provider and API key (see Layer 2). A local model is possible only if the machine has a suitable GPU.
- firecrawl MCP (optional): the user adds it to the agent's MCP configuration and exports `FIRECRAWL_API_KEY` in the environment. Run the server only from a pinned package version the user has approved (`npx` of an unpinned package executes remote code); ask before first use.

## Output
Report per layer: what ran, what passed/failed, what was fixed, and what was skipped (with the exact missing prerequisite). End with the green/red state of the deterministic suite — that is the source of truth.
