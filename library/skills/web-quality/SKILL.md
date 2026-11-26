---
name: web-quality
description: "Use to audit/improve web pages: performance, Core Web Vitals, WCAG accessibility, SEO, best practices."
---

Evidence-led web quality audit (performance, CWV, accessibility, SEO, best practices). One flow: measure -> triage -> fix list -> re-measure.

## Pick the tier

- **LOW - static review (no runnable page, or quick pass).** Read the HTML/CSS/JS/templates with the agent's search/read tools and walk the checklist in the area references. Every finding is a **hypothesis**, not a measured failure; say which measurement would confirm it.
- **MEDIUM - live audit (default when a URL or dev server is reachable).**
  1. Navigate with the agent's browser tool (or Playwright) for page state, screenshots, DOM and a11y-tree inspection; useful capabilities: single-session CWV readout, device/network/CPU emulation, ARIA snapshot, console errors, network requests. Local dev: build + `start`, not `dev` (dev mode skews perf).
  2. Chrome DevTools MCP server, if connected (read each tool's schema first; headless, isolated profile):
     - `lighthouse_audit` -> Accessibility, SEO, Best Practices, Agentic Browsing. It **excludes performance**. Navigation mode reloads the page; use snapshot mode when reload would lose state. Never run it on an unsaved form or destructive flow.
     - `performance_start_trace` (reload + auto-stop) then `performance_analyze_insight` for only the failing insights (`LCPBreakdown`, `LCPDiscovery`, `DocumentLatency`, `RenderBlocking`, `ThirdParties`). Trace summaries include CrUX p75 when the URL/origin is eligible.
     - `take_snapshot` (text a11y tree) before screenshots; filter/paginate network and console lists.
  3. Fallback if no DevTools MCP is available: `npx lighthouse@<pinned-version> <url> --output=json --output-path=<file>` (ask the user first, since npx downloads and runs remote code; state the version you pinned; do not add it as a permanent dependency).
- **HIGH - deep performance / field data.** Throttled traces (set viewport, CPU rate, network profile explicitly, confirm, reset after), >=3 equivalent runs with median + range, network waterfall review, third-party attribution, RUM design (`web-vitals`), CrUX/PageSpeed Insights comparison, header review on the deployed origin. Use subagents (if available) to audit independent routes in parallel (each its own browser tab/profile). Adding a RUM endpoint/vendor/cookie needs user approval first.

## Audit flow

1. **Scope**: representative URLs, key journeys and states (public vs authenticated, mobile vs desktop; default mobile), staging vs prod. Record browser/tool version, viewport, throttling, cache state, consent/experiment state.
2. **Measure** (MEDIUM): one trace + one Lighthouse run first; do not dump the whole DOM/network/console. Repeat the headline metric 3x and report the median. If nothing can run, switch to LOW and label everything a hypothesis.
3. **Triage** into buckets, keeping evidence types separate (see table):
   - CWV: LCP <= 2.5 s, INP <= 200 ms, CLS <= 0.1 at p75 (all three must pass).
   - Accessibility: automated findings + manual keyboard/screen-reader checks (automation finds ~30-50%).
   - SEO: crawl/index controls, titles/meta, canonical, structured data, mobile.
   - Best practices: HTTPS/mixed content, security headers, console errors, deprecated APIs, dependency vulnerabilities.
   - Agentic Browsing (Lighthouse 13+): semantic controls in the a11y tree; do not equate it with ranking or AI visibility.
4. **Fix list**: severity Critical (security holes, complete failures) -> High (CWV fails, a11y blockers) -> Medium (perf/SEO opportunities) -> Low. Each item: category, file:line, impact, evidence (measured / trace-backed / source hypothesis), concrete fix.
5. **Verify**: re-run the same measurements under the same conditions, re-do affected manual flows, and state what is still pending (field data needs new real visits; CrUX is a 28-day rolling window).

| Evidence | Meaning | Use for |
|---|---|---|
| CrUX / RUM (p75) | Real users | Is there a user problem? Missing CrUX = unavailable, never "passing" |
| DevTools trace | One session under stated conditions | Root cause of LCP/INP/CLS |
| Lighthouse | Synthetic navigation | Regression guard; score is a diagnostic, not a goal |
| Source review | Potential issues | Hypotheses only |

## Rules

- Measure before optimizing; edit only code tied to a measured bottleneck. Never attach generic ms savings to a fix; quote the before/after metric.
- Prefer a discoverable `<img fetchpriority="high">` for the LCP image; add `preload` only if the trace shows late discovery. Preload/preconnect only what the trace justifies.
- Reserve space for images, embeds, ads, banners (width/height or `aspect-ratio`); never insert content above visible content.
- Native HTML before ARIA; no `outline: none` without a replacement; no zoom-disabling viewport.
- Passing Lighthouse or axe does not mean accessible: always keyboard-test (Tab order, focus visible, no trap, Esc closes dialogs) and name the manual checks done/pending.
- Security headers must be verified on the response (browser network view, `curl -sI <url>` on bash, or `Invoke-WebRequest -Method Head` on PowerShell), not inferred from config. HSTS only after all subdomains serve HTTPS; CSP via nonces/hashes, report-only first. Do not send `X-XSS-Protection`.
- Structured data must describe visible content; syntax-valid is not rich-result eligible. No fake ratings/reviews.
- Do not use external web-design rule lists fetched at run time; use the references here plus the project's own design system.
- Do not push, deploy, or submit anything while auditing; fixes stay local until the user says otherwise.

## Output format

Evidence table (signal | scope/conditions | result | source) -> findings by severity -> per-category summary (measured status + manual checks pending) -> prioritized fix order -> verification status and remaining uncertainty.

## References

- `references/cwv.md` - load when LCP/INP/CLS is failing or a trace points at one.
- `references/performance.md` - load for budgets, loading strategy, images/fonts/caching, third parties, measurement conditions and RUM.
- `references/accessibility-wcag.md` - load for WCAG 2.2 criteria, patterns (modal, skip link, errors, tabs, live regions) and the audit checklist.
- `references/screen-reader-testing.md` - load when verifying with NVDA/VoiceOver/Narrator/TalkBack or debugging announcements.
- `references/seo-structured-data.md` - load for crawl/index checks, meta, sitemap, hreflang, JSON-LD templates, crawler controls.
- `references/best-practices-security.md` - load for headers, CSP/Trusted Types/SRI, deprecated APIs, console/error hygiene, permissions.
