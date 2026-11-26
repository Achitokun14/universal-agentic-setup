---
name: ui-variant-prototyping
description: "Use to explore a UI piece as several genuinely different live variants behind a switcher, then promote one"
---

# UI variant prototyping

Take one described UI piece ("a toast", "the pricing card", "a hold-to-delete button"), build several genuinely different versions, show them one at a time behind a small switcher, and promote the winner. All value is divergence: three tints of one idea teach nothing. Reviewing existing UI, planning fixes and choosing dependencies are other jobs.

## Rules

1. Never touch production code while exploring. Everything lives in an isolated prototype surface; integrate only the variant the user picks.
2. Each variant diverges on a NAMED axis (layout, density, personality, motion, interaction model). Name each variant by direction ("Quiet", "Editorial", "Dense"), never "Option A". Two variants differing only in accent color or copy are one variant.
3. Every variant fully works: real interactions and motion, realistic product-shaped content, no lorem ipsum, no dead buttons.
4. Every variant meets the motion/craft bar individually (ease-out entrances, never ease-in; UI motion under 300ms except modals/drawers/sheets/toasts; correct `transform-origin`; transform/opacity preferred; reduced motion handled). A sloppy variant just loses on execution.
5. The switcher is harness chrome, not a contestant: its look follows `references/picker-spec.md` and never adopts the project's tokens.
6. After the choice, delete the prototype surface unless the user asks to keep it. Never push, deploy or publish anything.

## Procedure

1. **Scope**: one piece per run; if the brief spans several, pick the highest-leverage piece, say why, offer the rest as later runs. Restate the brief in one sentence (what, where it lives, what it must do).
2. **Recon**: stack, styling system, motion library, tokens (colors, radii, spacing, fonts, easing/duration), product personality (bounds the boldest variant), render context (background, neighbors, sizes). No project: use a restrained default (neutral grays, one accent, system fonts) and a single standalone HTML file.
3. **Choose directions**: default 3 variants, up to 5 on request; list name and axis for each before writing code; if two share an axis position, replace one.
4. **Build the harness**: in a project, an isolated route/page (for example `/prototypes/<slug>`), one file per variant plus a small harness; nothing in production imports from it. Render ONE variant at a time, full size, in realistic surroundings (a toast needs a page behind it, a card needs siblings); thumbnails distort scale. Switching is instant (a 100+ times per session action gets no animation).
5. **Verify**: run it, flip through every variant, exercise every interaction, check the console is clean; use the agent's browser automation for screenshots when available.
6. **Hand off and stop** with a table `# | Variant | Axis | Right when | Cost`; sell each honestly, do not pre-pick; if asked for a favorite, justify from product personality and frequency of use. Say where the picker runs and which keys flip.
7. **Promote on selection**: integrate into the production location following project conventions, run the project's checks, delete the prototype surface. Another round ("riff"): keep the harness and diverge around the direction the user gravitated to. If two variants converged while building, cut one and say so.

## References

- `references/picker-spec.md`: load when building the switcher (look, keyboard contract, URL persistence, replay).
