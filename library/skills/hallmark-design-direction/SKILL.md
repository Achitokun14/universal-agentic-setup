---
name: hallmark-design-direction
description: "Use when building a new web page from a prompt that must not look AI-generated: gates, shapes, themes"
---

# Hallmark design direction

Anti-template doctrine for building a NEW page: a hard floor against model-default tells, a chosen direction (shape + theme) that differs from the last build, one idea per screen. Complements `ui-design` (general UI craft, motion, a11y); this skill adds the gates, the shape and theme catalogues and the fixed intake. No CLI or linter is needed: every check below is manual or grep-able over the CSS/HTML you wrote.

## Flow

1. **Pre-flight.** Read the project first: an existing `DESIGN.md`/`design.md` (locked system, overrides everything), fonts, palette, tokens, framework. A named real brand: load `references/fonts-and-brand-truth.md` before choosing any colour.
2. **Ask once, in one message** (skip if the prompt answers it or nobody can answer): (a) material: real photos, screenshots, numbers, quotes, logos the page may show; (b) audience; (c) the one action; (d) tone as an extreme (editorial, brutalist, soft, utilitarian, luxury, playful, technical, austere; "clean and modern" is not a tone). "Go ahead" = infer, state inferences in one line. Facts are never inferred: a number, quote or logo not given is absent; a missing picture is a labelled slot.
3. **Genre** (silent): AI/generative/music/video/dark -> atmospheric; SaaS/API/B2B/dev tool -> modern-minimal; playful/kids/games/community -> playful; else editorial. Voice rules per genre: `references/genres-and-themes.md`.
4. **Shape.** Name the visitor's job (subscribe, book, buy, try, hire...) and where real sites of that category put the action and what sections they are built around. Pick ONE of the 21 shapes in `references/macrostructures.md` (vocabulary, not a menu) or describe your own as a six-axis fingerprint. Mirror test: would a neighbouring prompt get this exact combination? If yes, change one decision.
5. **Theme.** Pick one material from `references/genres-and-themes.md` that can carry the prompt (motion, photos, code), or go custom (own idea, own palette/faces) only if asked. A theme is a material (paper, ink, faces, surfaces), never a layout.
6. **Declare in the reply** (a short Picks block): inferences, material inventory (real / pictures / absent), shape, theme, hero posture, signature (the one thing a visitor remembers, shown on the first screen), anything waived with a reason.
7. **Pre-emit critique** before coding: score the plan 1-5 on Philosophy (has an argument), Hierarchy (survives a squint), Execution, Specificity (could belong to no other product), Restraint, Variety. Anything under 3: revise the plan first; name the weakest axis and the fix.
8. **Build**, then **sweep** with the gates; render at 375, 1280x800, 1440x900, 1920x1080 using the agent's browser tool or a headless browser script; one fix batch, one confirming round.
9. For an independent look use `hallmark-redesign-review` (hero review + finish review in a fresh-context subagent).

## The Floor (never waived)

1. Colours and fonts only via tokens declared at `:root`; no literal colour/`font-family` below the token block.
2. No `transition: all`; never animate width/height/top/left.
3. No decorative eyebrow above headings (small type carrying a fact, destination or identifier passes the Eyebrow test in `gates-finish-judged.md`); no label in tracked caps or small caps (labels, captions, table heads, tags, nav links = body face, a step smaller, sentence case, untracked). Capitals only as wordmark or a theme's uppercase display.
4. No one italic/coloured/bold word inside a heading; no middle-dot meta strings, arrows glued to link text, decorative status dots.
5. No purple-to-blue gradient, card inside a card, emoji as icon, hand-drawn browser/OS window.
6. No invented metric, testimonial, logo wall, case-study count, or fake "Sent" success on a form with no endpoint.
7. `overflow-x: clip` on html and body; no `100vw`; no hero in `vh` (use `dvh`/`svh`); image grid tracks `minmax(0, 1fr)`.
8. Visible instant `:focus-visible` on every interactive element; every animation has a `prefers-reduced-motion` fallback; content visible with scripting off.
9. Hero headline + one sentence + primary action visible at 1280x800; about 80 words per 900 px window; container capped and centred so gutters, not measure, grow at 1920.
10. Contrast: body 4.5:1, large text/icons/rings/field edges 3:1; button text paired with an accent-ink token.

Full gate tables (Reflex tier, tells, fixes, Finish checks, grep patterns): `references/gates.md`.

## References

- `references/gates.md`: load before the pre-emit critique (Reflex tier).
- `references/gates-finish-judged.md`: load for the sweep (grep hints, Finish checks, judged clauses).
- `references/macrostructures.md`: load at Step 4 (shape) or when a run has no signal.
- `references/genres-and-themes.md`: load at Step 3/5 (genre voice, postures, theme anatomy).
- `references/themes-editorial-playful.md` and `references/themes-minimal-atmospheric.md`: load at Step 5 to pick one of 50 theme materials.
- `references/craft-and-copy.md`: load while building (type, colour, surfaces, copy, finish).
- `references/interaction-motion-texture.md`: load for forms/stateful controls, scroll stories, texture.
- `references/dark-data-responsive.md`: load for dual-mode pages, charts/dashboards, unusual layouts.
- `references/fonts-and-brand-truth.md`: load for custom font picks or when the prompt names a real brand.
- `references/design-md-contract.md`: load when the user asks to lock/export the design system.

Attribution: distilled from https://github.com/Nutlope/hallmark (MIT). See `SOURCES.md`.
