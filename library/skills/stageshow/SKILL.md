---
name: stageshow
description: "Use for faux product UI: mocked app windows, phones, bento tiles, hero stills, animated cursor demos."
---

# Stageshow

Design doctrine for miniature product UI: a believable interface, framed with intent, shown as one still or one short animation in which one thing happens. The viewer recognizes the screen and sees the thing happen.

## What is NOT here

The upstream project ships a React kit (Stage, Window, Phone, Roll, Count, Fly, Connector and more), gold examples and film scripts. None of that is included. Build every part yourself in plain React and CSS, or with the host project's own components. References below describe behaviours to implement, never imports. Do not fetch the upstream kit and do not claim a kit part exists.

## The one idea

It reads as a real product, simplified to what the viewer needs, framed with intent, and every motion has a cause.

Five ways it fails:
- **Too much:** real text in every row, numbers everywhere. More detail looks more generated.
- **Wireframe:** two gray blobs and a button; too small, or stripped of what made it recognizable.
- **Boxed:** a whole window shrunk into a card with even margins; a screenshot pasted in, not a product shot.
- **Flat:** every object the same weight in the same bordered card; the eye has nowhere to land.
- **Bland:** a gray window with a cursor, ignoring the brief's look and energy (blueprint, glass, island, mascot). Build the brief's look to these rules.

The fix: a full, structured screen in quiet grays, real words only where the story is, placeholder bars elsewhere, room to breathe, a crop that puts the eye on the story. Simplify the words, not the context. An empty corner, a void under a list, rows spread to fill a pane, a window floating on a plate (a tinted backdrop): unfinished, not calm.

These are authored illustrations, not browser automation: a scripted timeline sets scene state and draws a cursor pressing.

## Rules

1. Plan before code, in six lines: medium (still, loop, once-in-view, hover) and page; ground and width; focal object; the action; the payoff; what is left out.
2. Design at the size it will be seen and show it 1:1: about 720 x 340 hero beside copy, 900 to 1100 wide full-width hero, about 400 x 300 card. Never under about 320 wide for a demo (bento tiles and satellites may be smaller). Anything that can sit in a phone column also gets a separate compact design near 358 wide: a recomposition, not a squeeze.
3. Take the look from the product: tokens from its code (CSS variables, Tailwind config, theme files) or the computed styles of a button, input, menu and card on its public site. Take values, never unlicensed fonts, images or logos. Expose them as CSS custom properties on the demo root. Fidelity: minimal (all bars), standard (words where they carry meaning, bars elsewhere, default), realistic (real content everywhere; for hero scale, a named real product, or a list/page subject).
4. Pick the story shape (`references/motion.md`): how it feels, a flow, or what the system does. 3 to 5 beats and a payoff in 10 to 16 seconds; no cursor move you cannot explain; between a richer story and a calmer frame, choose the frame.
5. Build the screen: count the real strings (usually 3 to 7), everything else is placeholder bars; mark each element the cursor touches (`data-target`) and measure its rectangle at runtime, never hard-code coordinates.
6. Choreograph: keep what appears mounted and toggle it so exits animate; animate relationships (a new row carries the rows below it); beats overlap, groups stagger, the payoff holds, the loop ends where it began or resets with a visible cause.
7. Rehearse (`references/verify.md`): set the poster frame first, capture frames with the browser tool at the shown width and 390, step every press, morph and the loop seam, fix the largest visible fault first (framing, then hierarchy, then motion, then polish).
8. Hand over a short rehearsal note listing widths, looks and states captured and what you did not check.

## Faults that come back every round

- Content that swaps instead of moving.
- Gray bars where the eye lands; filler belongs at the edges.
- A plate behind the window, or a window floating with air on four sides; the hero fills at least two thirds of the stage width and runs off an edge.
- Empty bands, cut controls, sliced shadows.
- Stock AI marks (sparkles, purple as the AI color) and invented logos (a letter in a colored square).
- Busy rows and uneven insets.
- Long holds, and a loop reset with no cause.
- A text selection that is not under the I-beam every frame.
- A status bar or home indicator drawn by hand on a phone, instead of one shared phone-frame component.
- A centered amount centered together with its currency sign.

## Hard limits

- Demos use fixed fake data and never call live services or real accounts.
- Real people, company marks, app icons and photos only when the user supplies them or their license allows it; otherwise use plain text wordmarks, neutral avatars and CSS or vector shapes. Product names and marks stay with their owners and imply no endorsement.
- Never draw platform chrome from memory: open the real app or a screenshot first.
- A demo brings no full-page wrapper and scopes its CSS under one root class.

## References

- `references/framing.md`: load when deciding crop, bleed, gutters, satellites, layout, phone or compact formats, a bento grid or a background.
- `references/craft.md`: load when building or reviewing the still frame: restraint, type, spacing, icons, color, chrome and devices.
- `references/motion.md`: load when scripting any movement: story, loops, easing, changing text, arrivals, cursor, drags, scrolling, phones, annotation lines.
- `references/verify.md`: load before handing over: capture procedure, checklist, symptom-to-fix table, reviewer brief and note template.

Distilled from https://github.com/benjitaylor/skills (MIT, Benji Taylor; stageshow package). Written in the distiller's own words. See `SOURCES.md`.
