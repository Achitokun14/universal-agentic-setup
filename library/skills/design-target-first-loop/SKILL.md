---
name: design-target-first-loop
description: "Use to start a UI build from references: choose a mockup direction, lock static layout, then add motion"
---

# Design target first loop

A front-end workflow for turning a short brief plus visual references into a built page without long adjective prompts: pick the target on a mockup sheet, lock the static layout, add motion last, and give feedback in a form the agent can act on. It orders the work; the rules for each stage live in other skills.

Why: words like "modern" or "sleek" give a model no picture. References and a concrete target do.

## Steps

1. **Brief, short.** Two to five lines: what is sold or shown, who for, the one action. No adjective lists. Put the weight on references.
2. **Reference set.** Ask the user for about 9 to 12 references (screenshots, pages, short videos) that show section geometry, whitespace ratio and type contrast. Fewer than 5: say the target will be loose and ask for more. For a live reference URL, use the agent's browser tool (or a headless browser script) to scroll the whole page, take full-page shots at desktop and phone width, and write down in your own words what each reference contributes. Take from several references; never copy one 1:1. For exact numbers from a reference, use `style-extraction-diff`.
3. **Target sheet before the build.** Build three genuinely different directions as light HTML/CSS mockups on ONE preview page, side by side, each with a phone-width preview. Name them by direction, not A/B/C. No app state, no data wiring. Show the page (browser screenshot), then let the user pick one or name elements to combine. Record the choice in a short `TARGET.md` (direction, what to keep from the others). For one component swapped live, use `ui-variant-prototyping` instead.
4. **Static first.** Build the full layout with zero animation. Lock hierarchy, spacing, type scale and responsiveness (desktop and about 390px) before any motion. Do not mix layout and animation in one pass.
5. **Motion second.** Only after the static layout is accepted. For each wanted transition, take a reference clip or recording, step through it frame by frame, log duration and easing per beat, then write original motion with those mechanics in the project's own stack. Hand off to `animation-choreography`; audit with `animation-audit-suite`.
6. **Judge cold.** Before calling a stage done, have one fresh-context reviewer subagent (if available; otherwise re-check cold yourself and say "in-thread") compare screenshots with the references and the target, scoring each dimension. Agents over-grade their own work; if the user gives a score, treat the gap as an offset. For a numeric multi-round loop use `cook-visual-match`.

## Feedback formats (use and ask for these)

- **Annotated screenshot:** the user marks the area on a screenshot, you read the mark and the words. When you cannot tell what a mark means, ask.
- **Reverse-describe:** when something feels wrong and nobody can say why, ask the agent to describe what it built: grid, font sizes and weights, hex values, spacing scale, radius. Read that description, find the offending token, then fix that token. Never reply to "the colors feel off" with a random re-tint.
- Vague adjectives from the user: restate them as a measurable change ("heading 56px to 72px, gap 24 to 40") and confirm before editing.

## Stacking rule

Use ONE page-level art director per page (for example `hallmark-design-direction` OR `taste-art-direction-gate`, not both): two of them issue conflicting token and layout rules. Layer instead, in order: page director, then a product-moment skill (`stageshow`) for the hero demo, then motion polish (`ui-design` motion references, `animation-audit-suite`). If a second director is already active, drop the one with fewer constraints on this page and say which.

## Slop check

Banning one cliche only makes the model reach for the next default. Judge the rendered page for clusters of tells appearing together (purple-blue gradients, nested cards, invented addresses, eyebrow caps over every heading, uneven gutters, broken effects); a single deliberate choice is fine. Use `taste-art-direction-gate` or `hallmark-redesign-review` for the full check.

## Never

- Start the full build before the user chose a target.
- Add animation in the layout pass.
- Report a score or match you did not measure or look at; say "not checked".
- Publish, deploy or push without explicit user confirmation.

## References

- `references/target-sheet.md`: load at step 3 when building the three-direction page.

Distilled from notes on Leon Lin's design workflow and the Hallmark/Stageshow stacking advice (upstream: https://github.com/Leonxlnx/cook, MIT); written in the distiller's own words. See `SOURCES.md`.
