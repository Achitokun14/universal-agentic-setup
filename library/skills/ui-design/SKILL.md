---
name: ui-design
description: "Use for designing, building, critiquing or polishing web UI: layout, type, color, motion, a11y, DESIGN.md"
---

# UI design

Make web interfaces with a point of view and a real quality floor: new pages and components, redesigns, critiques, audits, polish, a11y and metadata fixes, design-system capture. Text-only skill plus an offline search script; it runs no launcher, hooks, network calls or telemetry. If you ever run an impeccable-derived tool yourself, set `DO_NOT_TRACK=1`. Read PRODUCT.md and DESIGN.md straight from the project; never invoke an `impeccable ...` command.

## Pick the tier

**Low: small fix, deslop, a11y, metadata, spacing.** Edit directly, no questions, minimal diff. Load `references/quick-fixes.md` (baseline-ui + accessibility) and, for SEO/share tags, `references/quick-fixes-metadata.md`. Match the project's existing stack and tokens.

**Medium: new component or page with a clear brief.**
1. Read the brief, PRODUCT.md/DESIGN.md if present, and the existing components.
2. Plan per `references/aesthetic-direction.md`: 4-6 named hex colors, type roles, layout concept with an ASCII wireframe, one memorable move; review the plan against the brief and revise anything generic.
3. Look up stack rules offline (standard-library Python 3 script, no network; run from this skill's folder):
   - macOS / Linux (bash): `python3 scripts/search.py "<query>" --stack astro|svelte|nextjs`
   - Windows (PowerShell): `python scripts\search.py "<query>" --stack astro|svelte|nextjs`
   Other modes (domain search, `--design-system`) and the `PYTHONIOENCODING=utf-8` tip for garbled output are in `references/stacks.md`.
4. Apply motion craft from `references/emil/design-eng.md` and `references/emil/animate.md`; then `references/impeccable/craft-floor.md` before the first edit.
5. Build, render, check (see Verify).

**High: new surface, redesign, critique/audit, design system.**
Use the impeccable playbooks in `references/impeccable/`: shape -> new-work-1/2/3 -> craft-floor -> critique / audit / polish / harden. Choose the visitor mode first (`modes.md`). Capture PRODUCT.md and DESIGN.md (`product-design-md.md`). Run `critique.md` or `audit.md` for evaluation. Render and inspect at shipped sizes; use a subagent (or a fresh session) for an independent review when available. `impeccable/routing.md` maps a request to a playbook.

Optional heavier alternative: the open-design desktop app (`nexu-io/open-design`, about 3.4 GB, needs the user's approval) is not part of this skill; mention it only if the user asks for a full GUI design tool.

## Core rules

- **The brief wins.** Honor pinned aesthetics, fonts, palettes and eras even over a default warning. Redirecting a clear brief toward your taste is failure.
- **Refinement preserves; redesign replaces.** Refinement keeps identity, behavior, copy and everything outside scope; ask before changing factual copy or adding claims. Redesign keeps product truth and treats the old look as an anti-reference.
- **Visual authority is evidence, not a filename.** A missing DESIGN.md alone does not mean greenfield.
- **Modes:** Persuade (landing, marketing: bold, committed world), Operate (apps, dashboards: precision, familiar controls, density), Read (docs, articles: structure then comfort, 60-75ch), Experience (portfolios, galleries: the artifact leads). Choose from the requested surface, not the product.
- **Defaults are not choices.** Avoid, unless the brief asks: cream background + high-contrast serif + terracotta accent; near-black + one neon accent; broadsheet hairlines; identical rounded-card grids with one radius and one soft shadow; gradient text; an eyebrow label above every heading; 01/02/03 markers without a real sequence; hard offset shadows outside a neobrutalist world; colored side borders over 1px; emoji as icons; a hero-metric template; a modal where inline would do. Model-default fonts (Fraunces, Playfair, Space Grotesk, DM Sans, Inter-as-display, Instrument Sans and similar) need a reason no other face could satisfy.
- **Color:** pick a strategy first (restrained, committed, full, drenched); color owns regions rather than sprinkling accents; light or dark follows a one-sentence use scene; roles not swatches; OKLCH for new palettes; contrast body 4.5:1, large text and controls 3:1; never color alone.
- **Type:** one family is often right; body at least 16px, measure 45-75ch (under 80), balanced headings, fixed rem scale on product UI, tracking tightens as size grows, tabular numerals for data.
- **Layout:** group by proximity before adding containers; one spacing rhythm on a 4-based scale; more space above a heading than below; structural responsiveness (reorder, collapse), not just fluid type; nested cards are always wrong.
- **Motion:** one authored moment beats scattered reveals. Gate by frequency (no animation on 100+/day or keyboard actions). Ease-out, UI under 300 ms, transform/opacity only, never `scale(0)`, anchored popovers scale from the trigger, interruptible (transitions or springs) for rapid triggers, `prefers-reduced-motion` gentler not zero, hover gated by `(hover: hover) and (pointer: fine)`, content visible by default. Implementation with GSAP: use the `gsap-motion` skill.
- **States and floor:** default, hover, focus, active, disabled, loading, error, empty; visible keyboard focus; real content and working controls; responsive to mobile; theme the browser-default surfaces (selection, caret, scrollbars, focus rings).
- **Copy:** controls name their action ("Save changes"); errors state the problem and the recovery; same name for an action through the whole flow.
- **Content truth:** author demonstration data at full fidelity and label it synthetic; never invent prices, customers, benchmarks or capabilities.
- **No loaded symbols:** world references never justify emblems of militarism, supremacy or hate movements as motifs or ornament.

## Verify (render, do not guess)

Use a browser automation tool (if available; otherwise ask the user for screenshots or use DevTools) to load the result at about 390 and 1440 px (plus the user's width), settle entrance animations first, open every capture to confirm it shows what its name claims, drive interactive states (open, hover, focus, error, empty, overlong text), then fix in one batch and re-check once; two rounds is the ceiling. Check the console. For performance, CWV, WCAG and SEO audits use the `web-quality` skill; to test flows in a running app use `web-testing`. Hand framework composition and performance to `vercel-next-react` (React/Next) or `astro-svelte` (Astro/Svelte). Use `plan-and-design` for multi-ticket planning. For image generation use the agent's image-generation tool if it has one (not part of this skill).

## References (load on demand)

Foundations (`references/<file>`)
- `aesthetic-direction.md` base aesthetic direction (Anthropic frontend-design, condensed)
- `quick-fixes.md`, `quick-fixes-metadata.md` ibelick baseline-ui, accessibility, metadata, evidence-based audit
- `stacks.md` search.py usage, stack/Tailwind/shadcn notes, open-design note
- `web-artifact-bundle.md` optional single-file React artifact recipe

impeccable playbooks (`references/impeccable/<file>`)
- Direction: `routing.md`, `modes.md`, `operate.md`, `shape.md`, `product-design-md.md`, `new-work-1-direction.md`, `new-work-2-commit-build.md`, `new-work-3-inspect-finish.md`, `craft-floor.md`
- Evaluate: `critique.md`, `critique-lenses.md`, `audit.md`, `polish.md`
- Refine: `bolder.md`, `quieter.md`, `distill.md`, `harden-1.md`, `harden-2.md`, `onboard-1.md`, `onboard-2.md`
- Enhance: `animate.md`, `colorize.md`, `typeset.md`, `layout.md`, `clarify.md`

Emil Kowalski motion and craft (`references/emil/<file>`)
- `design-eng.md`, `animate.md`, `review-animations.md`, `animation-performance.md`, `animation-vocabulary.md`, `break-ui.md`, `apple-design.md`, `mobile-native.md`, `pick-ui-library.md`

Scripts: `scripts/search.py` (+ `scripts/data/`, MIT, offline stdlib Python; licence `scripts/LICENSE-ui-ux-pro-max.txt`).

Licenses: impeccable Apache-2.0 (pbakaus), emilkowalski/skills MIT, ibelick/ui-skills MIT, ui-ux-pro-max MIT, frontend-design Apache-2.0; each reference file carries its source line.
