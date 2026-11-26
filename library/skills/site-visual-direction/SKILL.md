---
name: site-visual-direction
description: "Use when choosing landing-page visuals: photos, product UI cards, diagrams, logos, grounds, effects"
---

Distilled from https://github.com/Leonxlnx/taste-skill (MIT, (c) 2026 Leonxlnx). Everything here is described in prose; none of the upstream repository's components, backgrounds, effects or scripts are copied or run.

Decide what picture each section carries, where it comes from and what it may never be. Use with `taste-art-direction-gate` (page decisions, layout, browser check) and `landing-copy-voice` (words). Not for illustration or brand-identity design.

## Pick the tier

- **Low** (one picture slot, one icon, one card): apply the Rules and the matching reference.
- **Medium** (a page's picture plan): Steps 1 to 4.
- **High** (a site, or a place page with no client photographs): Steps 1 to 5, and list every stand-in on the report.

## Steps

1. **Inventory the client's real material:** logo, product photographs, CAD or renders, screenshots, trailer, key art, people, rooms, price lists. Each asset the brief names gets a designed slot that reads finished now: a frame at the file's final ratio holding a stand-in (a real `<video>` with a stand-in poster and a play control only when there is something to play; three to five stand-in photographs framed like captures for a screenshot strip; a CAD frame), named in a code comment for the client's file, never an empty or grey frame, never a line saying the file is missing.
2. **Choose each section's picture by kind** (table below), with the product, key art or place whole in at most the hero plus two sections.
3. **Source pictures** in this order: the client's own; licensed stand-ins (`references/photographs.md`); the product's real UI built as live HTML (`references/cards-and-fragments.md`); type or flat colour. Never a near fit, never mood in place of the subject.
4. **Grounds and effects** only as `references/grounds.md` and `references/effects-scenes.md` allow for the kind: flat colour everywhere, effects on tech pages only.
5. **Report:** every stand-in, its source and licence, and the client photograph that should replace it; every client slot and its stand-in; trademark line if real logos appear.

## What leads each kind

| Kind | Lead picture | Carries the other sections |
|---|---|---|
| Place | the client's photographs, 2 to 3 a screen (a remote place: its region's landscape) | rooms, goods, process details, the visit; see `references/place-page-plan.md` |
| Service | photographs of the work, team and rooms | people, steps, work cases, tools really used |
| Product, hardware | the product big and whole; stand-in photographs of its kind if none | use, parts close up, people with it, where it lives, a still diagram |
| Software | its own UI live in one app frame | UI fragments of its subject, diagram cards, real tool icons, one effect or scene (tech) |
| Gaming | key art; else the game's name over stand-in photographs of its setting | the world, the crew at work, trailer frame, screenshot strip, platform marks |

## Rules

1. A photograph never stands where an effect, a drawing or an empty box would; no mood stock in place of the subject.
2. Photographs are never filtered, printed, dithered, duotoned or graded by the page; no rounded or blurred photographs on a place.
3. Every `<img>` has alt text that says what it shows (new alt text, not the source file's title), real `width` and `height`, and a recorded source and subject.
4. Stand-ins are never shown with another maker's name or logo, never faces passed off as customers or staff, and nothing on the page says "stock" or "sample"; the report says it.
5. Real tools keep their own logo in their own colours; a fictional client's own mark is designed, not borrowed; no CDN call at runtime, vendor the files.
6. One light and one grade across a photograph set; one ratio per row.
7. Cards hold a picture and the picture holds the product: card, then panel, then fragment; never a third box.
8. Never copy a reference site's code, copy, pictures or signature effect; generic ideas only, built from the client's own content.
9. Effects, scenes, grain, gradient grounds, loops and counts belong to software, gaming and tech pages; other kinds stay flat.

## References

- `references/photographs.md`: load when the client has few or no photographs, when sourcing stand-ins, or when writing alt text and credits.
- `references/place-page-plan.md`: load for any cafe, bakery, guesthouse, shop, gym or local-studio page (length, sections).
- `references/place-variety-look.md`: load with the place plan for section compositions, order by trade, palette and type.
- `references/cards-and-fragments.md`: load when building feature cards, card panels or product UI fragments.
- `references/diagrams-and-icons.md`: load when building diagram cards, integration grids, file cards or any logo.
- `references/grounds.md`: load when choosing section grounds, brand or dark bands, or tech background treatments.
- `references/effects-scenes.md`: load before adding any shader, 3D object, big scene, video hero or product render.
