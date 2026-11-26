---
name: style-extraction-diff
description: "Use to extract exact hex, sizes and spacing from a reference or live page, and diff styles after edits"
---

# Style extraction and diff

Capture a reference's real numbers (hex, font sizes, spacing, radius, shadows) into a tokens file BEFORE writing code, then re-capture after edits and diff to catch style drift. Prose summaries of a picture lose exact values; numbers do not.

Complements the `ui-design` skill (if installed; its DESIGN.md writing mode extracts from the project's own code): this skill covers third-party references and the before/after diff.

## Steps

1. **Pick the target.** A live page (preferred: real computed values), or an image/screenshot/recording (estimated values). Ask the user which URLs or files; do not browse unrelated sites.
2. **Extract.**
   - Live page: use the agent's browser automation (browser tool, Playwright-style script or Chrome DevTools MCP; if none is available, ask the user to run the probe in the browser console and paste the JSON) at 1440 and 390 wide; run the read-only probe in `references/probe.md` for body, headings, links, buttons, inputs, cards, nav, and any element the user names. Also read `:root` custom properties.
   - Image: open at full size, read values by eye; for colors state them as estimates. Never claim a pixel measurement you did not take.
3. **Write `style-tokens.md`** beside the project (or into DESIGN.md when the user has one): color palette with role (page, surface, text, muted, accent, border), type scale (family, size, weight, line height, letter spacing per role), spacing steps seen, radii, shadows, border widths, transition durations and easings, breakpoints. Mark every value `measured` (from computed style or a script this session) or `estimated`.
4. **Build from the tokens,** as CSS custom properties; no literal colors or fonts past the token block. Cite the tokens file in the brief for any subagent (if used).
5. **Baseline before edits.** When changing an existing page (yours or an agent's), save a baseline probe of the same selectors first (`style-baseline.json` or a table in the file).
6. **Re-scan and diff after edits.** Run the same probe, compare per selector and property. Classify each difference as intended (matches the request) or drift (anything else: a changed hex, a new font size off the scale, shifted padding, lost focus style). Revert drift; report intended changes. Do not fix unrelated pre-existing drift unasked; list it.
7. **Report:** tokens captured and how (measured/estimated), diff result, drift reverted, what could not be read (cross-origin frames, canvas-drawn text, hover states not triggered).

## Never

- Copy a reference's code, copy text, images or assets; tokens are measurements to match, not material to clone.
- Write values you did not read; mark gaps "not captured".
- Edit or disable the page's scripts or styles to make a probe pass; the probe only reads.
- Send page contents or tokens anywhere outside the project.

## References

- `references/probe.md`: load at steps 2 and 6 for the read-only browser probe and the diff table format.

Distilled from compendium notes on pixel-level and live-style extractor skills (Tastemaker, Dembrandt); only the stated behaviour is used, no upstream code. Own words.
