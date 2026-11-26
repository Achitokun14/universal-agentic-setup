---
name: landing-copy-voice
description: "Use when writing business website copy: heroes, headings, buttons, brand voice, microcopy, AI-sounding text"
---

Distilled from https://github.com/Leonxlnx/taste-skill (MIT, (c) 2026 Leonxlnx); every example below is written for this skill.

Write page copy that says plainly what the business is and does, in a voice that fits this client and not the model's default. Pair with `writing-clarity` (sentence-level slop and rhythm, which this skill does not repeat) and `taste-art-direction-gate` (page layout). Not for fiction or long-form essays.

## Pick the tier

- **Low** (one heading, button or error message): apply Rules 1 to 5 and the device budget; return the text only.
- **Medium** (a page's copy): Steps 1 to 6.
- **High** (a site, or several pages built in one session): Steps 1 to 6 plus the cross-page sameness check and a cold reader.

## Why model copy is recognised

The old slop (elevate, seamless, delve) is mostly gone. The new tells look like good copy used identically on every page: one warm, wry, slightly literary voice for every client; the same devices in every section (a strip of three invented figures, two-fragment headings, "X, not Y", "No X. No Y.", a dry joke ending each paragraph, a pun in the footer); sincerity stated instead of shown (honest, calm, quiet, actually); invented specifics to look precise. Professional copy uses the same devices, but its details are true, each device is used once, each brand has its own voice, it takes a risk (names an enemy, admits a limit) and the page is uneven. Cause: missing input. The fix is facts and decisions, never synonyms: a swapped word is the next tell.

## Steps

1. **Fact sheet** from the brief, the client's files or their existing site, word for word where possible (table below). An empty field stays empty: its section shrinks or goes, and the report lists what the client must supply. Never a bracket, a "coming soon" or a placeholder on the page. A thin brief is no reason to stop; write the best page the facts allow. When a person is present and asked for copy (not a build), ask at most six questions in one message, most useful first: who switched to you from what and why; the one number you would bet on; the objection you hear most; what you are bad at or not for; a strange true detail of how you work; three real customer messages.
2. **Voice card** on the plan, never on the page: one register from `references/registers.md`, plus: pairs of qualities ("exact, not cold"), person (who is "you" and "we"), typical sentence length, humour budget, house words, and things to never say. Copy the client's own voice first: a writing sample or old site overrides the menu. With no steer, choose the register least like the last page written this session.
3. **Shape from the reader's questions:** what is this, is it for me, why believe you, how does it work, what does it cost, what if it goes wrong, what do I do now. Start where the reader is: unaware of the problem (open on a moment they recognise), aware (name it in their words), comparing (lead with the mechanism), already knowing you (the offer and the action). A section exists only if the brief has true material for it: five full sections beat eight padded ones; counts follow content (four real features are four cards; zero testimonials is a normal page). Vary what sits in sections: a list, a table, a short letter, one longer paragraph.
4. **Draft** with `references/section-moves.md`. Facts where adjectives want to go; proper nouns over categories (the tools by name, the street, the bus line); the mechanism in verb-led steps; the customer's pain in their words before the product; one admission a page, from the brief; proof beside its claim; numbers inside sentences with their unit; repeat the product's name instead of cycling "platform, tool, solution". Voice holds, tone moves: hero and story carry the most voice; prices, FAQ, booking and forms go plain because readers there are anxious; errors and confirmations are short and kind.
5. **Microcopy in the register:** form labels and errors, the sent message, empty states, the 404, the newsletter confirmation. A hand-tuned hero over a stock form error gives the game away.
6. **Check:** (a) read it aloud as the client and cut anything they would not say about themselves; (b) rival test: put a competitor's name, or the same trade in another town, into the h1, the sub-line and each heading; a line that still reads true says nothing about this client, so rewrite it from the fact sheet; (c) tally the device budget; (d) over-correction: the habit that replaced the one you removed ("rather than" multiplying, everything in pairs, every sentence a fragment); (e) sameness across pages: put the first headings side by side and break shared cadences or jokes; (f) High tier: give a fresh-context subagent (if available; otherwise a cold re-read) only the page text and ask what this is, who it is for, why this over the alternative, what it costs, what would make it hesitate, and which three lines sound like any other site. Never iterate to beat an AI detector.

## Fact sheet fields

| Field | Holds | Feeds |
|---|---|---|
| What it is | one plain sentence, no adjective | h1, sub-line |
| For whom, not for whom | best-fit buyer; who should look elsewhere | h1 or sub-line, one FAQ line |
| What they do today instead | spreadsheet, the big rival, the bakery across town, nothing | pain line, comparison |
| The true difference | what is true here and not elsewhere, with proof | claims worth a heading |
| Customer words | phrases from reviews, emails, the brief | pain line, headings |
| Numbers | each with its source | sentences |
| People | names and roles the brief gives | about block, a quote |
| Odd true details | history, an object, a ritual, the awkward bit | the texture you would otherwise invent |
| A limit | what it does not do, who it is wrong for, what is closed | one admission a page |
| An enemy | a habit or category ("re-typing invoices"), never the reader | pain line, one section |
| The offer | price, trial, booking terms, the one action | buttons, the close |

A limit and an enemy come from the brief or plain facts of the trade ("closed Mondays", "Mac only"); an invented flaw is still an invention.

## Device budget per page

None is banned; each works once. Over budget is a tell; far over is a tic.

| Device | Budget |
|---|---|
| Heading in two fragments "X. Y." | 1 |
| Number-pair heading "Four X, one Y" | 0 to 1 |
| Negation run "No X. No Y." | 1, only when each item is a refusal a buyer can check |
| Contrast "X, not Y", "rather than", "instead of", "without the" | 2 in all (count the forms together) |
| Dry closing line on a paragraph | 2, never in a row |
| Pun on the brand name | 1, never the h1 |
| Footer sign-off or pun | 0 |
| Strip of figures | only plain facts from the brief |
| Virtue words about ourselves (honest, calm, quiet, actually, genuinely, simply) | 0 (literal uses are fine: a quiet room) |
| Lists of three | only when there are three things, never in consecutive sentences |
| Eyebrow labels | 1 or 2 |
| Step numbers on cards | only where order is the content |
| Response-time promise, "Since [year]" | 1 each, from the brief, same wording wherever repeated |

## Rules for page copy

1. The h1 names the category (and the buyer or the place when the brand is unknown) in 2 to 8 words; a place: what and where in 40 characters.
2. The first screen holds one hard fact: a number, a place, a price or a date.
3. Every heading has a noun that names a thing; one brand line a page at most, never the h1.
4. Buttons are a verb plus what the visitor gets, 1 to 5 words; never "Learn more", "Discover", "Explore", "Click here".
5. At most two actions in the hero; the main action reads identically in nav, hero, close and phone bar.

Details: `references/copy-rules.md`.

## References

- `references/copy-rules.md`: load when drafting headings, buttons, sub-lines, form words, or deciding what may be assumed or invented.
- `references/registers.md`: load at Step 2 to choose a voice and match it to the trade.
- `references/section-moves.md`: load at Step 4 for the move for each part of the page and the microcopy examples.
- `references/model-tells.md`: load at Step 6 to audit a draft for model giveaways.
- `references/over-correction.md`: load after fixing a draft, to catch the habit that replaced the one removed, and for the cross-page sameness check.
