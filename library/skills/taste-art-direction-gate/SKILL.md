---
name: taste-art-direction-gate
description: "Use before building or restyling a business landing page, and to gate it with browser checks"
---

Distilled from https://github.com/Leonxlnx/taste-skill (MIT, (c) 2026 Leonxlnx); no kit files, scripts or assets are used.

Build the marketing site a good company would ship: it says plainly what is sold, shows the real thing on every screen, and looks made for this client rather than from a template. This skill fixes the decisions (kind of business, page rhythm, motion budget) and ends in a measured browser check.

Not for dashboards or app UI (use the `ui-design` skill, if installed, in its operate/app mode). Generic prose cleanup belongs to the `writing-clarity` skill; page copy belongs to the `landing-copy-voice` skill; pictures, cards, grounds and effects belong to the `site-visual-direction` skill (each if installed; otherwise follow the rules below).

## Pick the tier

- **Low** (one section, one fix): apply the Rules to that piece, render at 1440 and 390, done.
- **Medium** (a new page in an existing stack): Steps 1 to 7, with the references for the parts you touch.
- **High** (new site, redesign, a page the user calls generic or "AI-made"): Steps 1 to 7 in full, then one fresh subagent or session (if available) reviews the screenshots and the copy cold.

## Steps

1. **Brief.** Write: the kind (table below), what is sold, who buys, the one main action (the transaction: Book a room, Order a cake, Start a free trial; a place with neither: Get directions), and the real material the client has (logo, screens, photographs, prices, address, hours). Missing material stays missing and goes on the report; nothing is invented to fill it (prices, reviews, customers, figures, awards); the only exceptions are a coined brand name and, with the user's approval, placeholder hours and prices for a place as the `landing-copy-voice` skill allows (marked `data-assumed` and listed on the report).
2. **Reference check (gate 0).** Ask the user for two or three reference sites, or, with the user's approval, pick two in the same trade. Open each with the agent's browser automation at 1440x900 and 390x844 and note, in your own words, the hero composition, how tall sections run, the type scale and what the main picture is. Never copy a reference's code, copy, pictures or signature effect. No browsing available: say so and continue.
3. **Copy first.** Load the `landing-copy-voice` skill if installed (otherwise write plain, concrete copy); write all headings, buttons and microcopy before layout, so sections are sized by real words.
4. **Plan as screens.** Line 1: the kind. Line 2: grounds, type pairing, radius, button look, and one sentence on why the palette fits the trade. Then one line per section: id, its one idea, its picture and the picture's kind, its height (1 or 2 screens), and the purpose of any motion in it. Choose by the brief and the kind; avoid repeating the hero composition, palette, type pairing and section layouts of any page built earlier in the session.
5. **Build** in the project's own stack, one system for the whole page (tokens, grid, spacing, type scale, radius, button, card, link). Load the references below for the parts used.
6. **Browser check** (`references/finish-gate.md`): shoot and measure at 1440x900, 1024x768, 820x1180, 768x1024, 390x844, then walk 320 for overflow. Fix every listed failure in one batch, re-check; at most three rounds.
7. **Report:** the check result first; every waived check with its reason; every open failure; the kind and the choices of line 2; what could not be checked; every assumed fact; every stand-in picture and the client photograph that should replace it; contacts left as stand-ins.

## The kind decides

| Brief | Kind | May carry |
|---|---|---|
| App, SaaS, AI, developer tool, fintech app | software | own UI live in an app frame; tech extras |
| A game or its studio's launch | gaming | key art, world, trailer frame; tech extras |
| Hardware, a tech device | tech | product photos or its CAD views; tech extras |
| Other physical product or brand | product | photographs; flat grounds |
| People are hired: clinic, firm, agency, trade | service | photographs of work, team, rooms |
| People come to it: cafe, bakery, guesthouse, shop, gym, local studio | place | photographs, type, flat colour only |

A maker that also opens its door or teaches is a place (its web shop is the goods section). "Tech extras" (shader grounds, scenes, loops, counts, dark heroes, WebGL) belong to software, gaming and tech only. Everything else is photographs, flat colour, type, real icons, the hero entrance, one dealt moment and the hover layer.

## Rules

0. **The brief wins.** These are defaults for pages without a pinned look; when the user or client pins a font, palette, era or layout, follow it and note the departure on the report.
1. **No caption or description under any image or visual.** Credits go in one footer line.
2. **Every visual renders** at 1440, 1024, 768 and 390: no empty ground, no unloaded photo, no blank canvas; a failed effect shows its still.
3. **One section per screen.** The hero alone fills the first screen; every other section is one or two screens tall at 1440x900, with no neighbour heading peeking in.
4. **Equal left and right content edges;** one container for header, sections and footer.
5. **Motion in three places only:** the hero's one entrance on load, one or two signature moments in their own sections, and the hover/press layer. Nothing animates because the page scrolled, outside a moment's own section.
6. **Real pictures:** the client's photographs and product UI; licensed stand-ins only where the client has none, listed in the report; never mood stock in place of the subject.
7. **Real icons:** a known tool's own logo in its own colours, never a redrawn look-alike; trademark line in the footer.
8. **Plain words:** the h1 names the category and the buyer or place; one hard fact on the first screen; buttons are a verb plus an object.
9. **Contacts on a draft page:** only what the brief gives. Without it, give a street and district at most (no house number, postcode or coordinates), no phone, no register or VAT numbers, and an `.example` address for the form, listed on the report as the client's to supply.

## Never

- Cards, rows or tiles that fade or slide in on scroll; parallax on text; scroll-jacking; smooth-scroll libraries.
- Invented reviews, quotes, customers, awards or figures; stock photos passed off as the client's product, people or place.
- A drawn look-alike of a real logo; violet or lavender in the page's own design (third-party logos keep their colours).
- Editing or hiding content from your own check to make it pass (detecting automation, stripping aria-hidden, shrinking a failing element out of view).
- Outward actions (deploy, publish, push, sending the form) without explicit user confirmation.

## References

- `references/finish-gate.md`: load at Step 6, or when writing the report.
- `references/kind-rules.md`: load at Step 4 for what each kind's page plan holds and forbids.
- `references/layout-screens.md`: load at Steps 4 and 5 for section heights, the hero, equal edges and the grid.
- `references/system-tokens.md`: load at Step 5 for type, colour, buttons, nav, forms, access and head tags.
- `references/motion-layer.md`: load when adding any hover, entrance, loop or reduced-motion behaviour.
- `references/signature-moments.md`: load when choosing or building the page's remembered moment.
- `references/perf-budget.md`: load when images, fonts, video or WebGL are added, and at Step 6.
