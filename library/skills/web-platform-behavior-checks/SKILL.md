---
name: web-platform-behavior-checks
description: "Use after changing UI for layout shift, reduced motion, dark mode or modal dialogs: verify it in a browser."
---

Code that follows a platform guide is not proof that the page behaves. For every rule you apply to frontend code (layout stability, reduced motion, color scheme, modal dialog focus and inertness), run a browser check and record the evidence. Finish only when each applied rule is Pass, Fail (then fix) or explicitly Unverified with the reason.

Complements the `web-quality` skill (full CWV/a11y/SEO audits with traces and Lighthouse) and the `web-testing` skill (flows and regression suites), if installed. Use this skill for the narrow "did my change actually do what the guide says" check.

## Workflow

1. **Collect rules.** Take the guidance you are applying (project design system, MDN, web.dev, a framework guide; use web search, a docs-lookup tool, or the repo docs) and write each rule down with its source. Do not run unpinned `npx ...@latest` guidance CLIs; do not paste guide text into the project, write the code from the rule and cite the source in the report.
2. **Baseline.** When changing existing UI, run the matching check below before editing and save the number or snapshot.
3. **Apply** the change in the project's code.
4. **Verify.** Serve the built page with the project's own dev or preview server (for performance-sensitive checks prefer a production build and start, not dev mode). Run the matching check for every rule, under the same conditions as the baseline.
5. **Report** one row per rule (see Report). A rule with no browser check is Unverified; never mark it Pass because the code looks right.

## Driver

- Use whatever browser automation the agent has: a browser tool, a Playwright script (Node or Python), or Chrome DevTools MCP. Use a Chromium engine for the motion and color checks: media emulation of reduced motion is not available in every engine.
- Chrome DevTools MCP equivalents: its `emulate` tool takes a color scheme (`dark|light|auto`) and a reduced-motion preference (`reduce|no-preference|auto`) (each call replaces all emulation settings, so pass everything wanted at once), its snapshot tool gives the accessibility tree, and its script-evaluation tool reads computed styles.
- Inspection only: use read-only script expressions. Open dialogs by clicking the real trigger, never by calling `showModal()` from script.
- Restrict the driver to the local origin under test.
- Details and runnable snippets: `references/checks.md`.

## Checks (one per rule family)

- **Layout shift.** Rule: images, embeds, fonts, ads and late content reserve space. Load the same URL before and after, let shifts settle (a few seconds after load), read CLS (from a `layout-shift` PerformanceObserver, the driver's vitals reading, or a DevTools trace). Pass when CLS <= 0.1 and lower than baseline; a CLS of 0 with no shift entries means no shifts were recorded. Match the largest shift's timestamp to the code that runs then. A reload loses client-side state such as an open dialog.
- **Reduced motion.** Rule: animations honour `prefers-reduced-motion`. Emulate reduce, confirm `matchMedia('(prefers-reduced-motion: reduce)').matches` is true, then read the same computed property (`transitionDuration`, `animationName`, `transform`) on the animated element under reduce and under no-preference. Pass when the reduced value matches what the guide prescribes (a guide may keep a short fade and drop only scale/translate, so 0.3s -> 0.1s, not 0s). Identical values under both preferences mean the stylesheet ignores the preference. Computed styles do not show what the user sees: also screenshot or record the transition under each preference and compare.
- **Color scheme.** Rule: light and dark themes both work. Emulate dark, confirm `matchMedia('(prefers-color-scheme: dark)').matches`, read body `backgroundColor`, text color and `document.documentElement` `colorScheme`, screenshot; repeat for light. Pass when colors differ between schemes and match the guide (for example `color-scheme` set so form controls and scrollbars adapt). Reset emulation to auto when done; a call that sets one preference can reset the other, so set both when testing both.
- **Modal dialog.** Rule: a modal `<dialog>` made with `showModal()` makes the page inert, moves focus inside, closes on Esc, and returns focus to the opener. Check, in order: (1) an interactive accessibility snapshot while open lists only the dialog's controls; background links/buttons in it mean the page behind is reachable; (2) `document.activeElement` is inside the dialog on the element the design chose (focus left on the trigger or `body` is a Fail); (3) an attempted click on a background control has no effect (error that the element is covered, or no state change; a successful background click is a Fail); (4) after pressing Escape the page is listed again and `document.activeElement` is the trigger.

## Report

| Source / rule | Check | Result | Evidence |
|---|---|---|---|
| web.dev CLS: images reserve space | CLS before/after, same URL | Pass | CLS 0.23 -> 0, no shift entries |
| dialog guide: background inert | interactive snapshot with dialog open | Pass | Snapshot lists only Cancel, Delete |
| motion guide: reduced motion | computed `transitionDuration` under both preferences | Fail | 0.3s under both; guide expects 0.1s under reduce |

Quote the real command output as evidence and attach screenshots/recordings by path. State the browser engine and viewport used.

## Rules

- Same URL, viewport, engine and emulation for baseline and after; change one thing at a time.
- A Fail is fixed in the project code and re-verified; do not edit the check to pass.
- Do not alter the page with scripts to make a step look done (inserting controls, writing state, revealing hidden elements).
- Cleanup: reset emulation to auto and close the browser or tab.
- Do not commit, deploy or publish anything as part of verification.

## References

- `references/checks.md` - load when writing the actual browser probes (Playwright snippets, DevTools MCP equivalents, failure interpretations).
