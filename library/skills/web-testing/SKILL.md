---
name: web-testing
description: "Use to test/QA a running web app in a real browser: Playwright E2E, UI flows, click-path audits, regression tests; includes a cross-platform dev-server runner script."
---

Test a running web app the way a user does: explore, find failures, fix at the source, lock the fix with a regression test.

## Pick the tier

- **LOW - ad-hoc QA with the agent's browser tool.** No install, no repo changes. Use for "does this page/flow work", repro of a reported bug, visual check. Typical loop with any browser-automation tool: open the page at a stated viewport, snapshot the interactive elements, fill/click by role or label, wait for a visible text, then read console errors, failed network requests and take a screenshot as evidence. Also useful if the tool has them: accessibility-tree snapshot, device emulation, request stubbing, video recording, saved login state for a test account. Keep the run on localhost (restrict allowed domains if the tool supports it).
- **MEDIUM - Chrome DevTools MCP server, if connected** (read each tool's schema first; headless, isolated profile). Use when the bug needs console/network/DOM debugging: console messages, network requests (filter + paginate), text a11y snapshot before screenshots, script evaluation, emulation. Same rules as LOW; it is a debugging lens, not a test suite.
- **HIGH - committed Playwright suite in the repo** (regression gate, CI, cross-browser, flaky-test hunting). In a repo add `@playwright/test` as a devDependency with the lockfile's package manager (ask the user first; it changes `package.json`), then run it with the repo's runner (`pnpm exec playwright test`, `npx playwright test` where npm is used). Specs are committed, deterministic, and assert user-visible behavior. See `references/playwright-suite.md`. Use subagents (if available) to audit independent pages/stores in parallel.
- React component/hook logic (no browser needed): Vitest/Jest + Testing Library + MSW -> `references/react-testing.md`.

## Start servers safely: `scripts/with_server.py`

`scripts/with_server.py` is a single cross-platform Python 3 script (standard library only; runs the same on Windows, macOS and Linux with the stock interpreter, so no separate `.sh`/`.ps1` is needed). It runs one or more dev servers (no shell, `shell=False`), waits for ports, runs your command, then kills the whole process tree. Logs go to temp files; it fails fast if a server exits. Servers are split with shlex: no `&&`, pipes or `cd`; use `--cwd`.

#### macOS / Linux (bash)

```bash
python3 scripts/with_server.py --help
python3 scripts/with_server.py --server "pnpm dev" --port 3000 -- pnpm exec playwright test
python3 scripts/with_server.py \
  --server "python3 server.py" --cwd backend --port 8000 \
  --server "pnpm dev" --cwd frontend --port 5173 -- python3 check.py
```

#### Windows (PowerShell)

```powershell
python scripts/with_server.py --help
python scripts/with_server.py --server "pnpm dev" --port 3000 -- pnpm exec playwright test
python scripts/with_server.py `
  --server "python server.py" --cwd backend --port 8000 `
  --server "pnpm dev" --cwd frontend --port 5173 -- python check.py
```

Paths above are relative to this skill's folder; use the absolute path of the installed skill when running from the project. For Playwright projects prefer the config's `webServer` block when the suite owns the server lifecycle; use the script for ad-hoc scripts and non-Playwright commands. Prefer a production build (`build` + `start`) for performance-sensitive or hydration checks.

## Workflow

1. **Scope**: what changed (`git diff --name-only <base>...HEAD`), which routes/flows it touches, which states (logged out/in, empty/full, error, mobile). Never test prod mutations; use a local or staging target and test accounts.
2. **Baseline**: run the existing suite first (`pnpm test`, `pnpm exec playwright test`) and record red/flaky tests before changing anything.
3. **Explore** each affected flow in a browser (LOW/MEDIUM): observe -> act -> inspect fresh state -> capture console errors, failed requests, screenshots. Judge correctness *and* feel (loading states, error messages, layout at mobile width, keyboard use). Wait for the app to settle (visible text / network idle) before inspecting dynamic pages.
4. **Click-path audit** when buttons "do nothing" or after a state-store refactor: `references/click-path-audit.md` (trace handler call order against store side effects).
5. **Triage** by severity (blocker, major, minor, cosmetic); reproduce each defect with exact steps; find root cause in source before editing.
6. **Fix + lock**: smallest fix at the source; write a regression test that fails before and passes after (unit/RTL where possible, Playwright for real-browser behavior); re-run the failing probe plus the adjacent happy path. Do not weaken or delete existing tests to get green.
7. **Report**: per route Pass / Fail / Skip with the reason; issues with repro steps, evidence, fix status (verified / best-effort / deferred); the deterministic suite's final state is the source of truth. Template in `references/browser-qa-method.md`.

## Rules

- Prefer the agent's browser tool for exploration; write Playwright specs only for flows worth keeping. Do not stack a second browser driver for the same run.
- Selectors by role/label/text first (`getByRole`, `getByLabel`), `data-testid` as the escape hatch; never CSS-class or nth-child chains.
- No fixed sleeps (`waitForTimeout`); wait on a locator, URL, response or `expect(...).toBeVisible()`. Tests are independent, create and clean their own data, and never depend on order.
- Flaky = real bug in test or app: reproduce with `--repeat-each=10`, fix the race; quarantine with `test.fixme` plus an issue reference only as a last resort, and say so.
- Auth: use test accounts and `storageState` files that are git-ignored; credentials via environment variables or your secret manager, never hard-coded or printed. Do not import cookies from the user's real browser profile.
- Anything that needs an outside party (OAuth consent, real email/SMS, payments, 2FA) -> mark `Skip (needs human)` with the reason, or ask the user; never fake it. Skip tests that move real money or send real messages on non-test targets.
- Auto-fix only small, well-understood, low-risk defects. Architectural/schema/product-behavior decisions go to the report under "Decisions for a human". Stop and ask after two reverted fixes or a fix that sprawls across unrelated files.
- Commit or push nothing unless the user asks; report what changed and where.
- External posting, deploys, and public-URL scanning are out of scope here; use the `vercel-deploy` skill (if installed) for deploys and the `web-quality` skill for performance/a11y/SEO audits.
- Visual/UX-model exploration (agent-based vision UIs, remote VLM endpoints) is not part of this skill; use screenshots (and screenshot diffs if your tool has them) and judge the images yourself.

## References

- `references/playwright-suite.md` - load when creating/repairing a committed Playwright suite: config, POM, fixtures, auth state, mocking, flaky fixes, trace viewer, CI.
- `references/browser-qa-method.md` - load for diff-scoped QA, route mapping, scenario matrix, triage/fix loop and report template.
- `references/click-path-audit.md` - load when UI controls do nothing or after shared-state refactors.
- `references/react-testing.md` - load for component/hook tests (RTL, Vitest/Jest, MSW, axe) and the unit vs E2E boundary.
