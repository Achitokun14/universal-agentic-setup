---
name: hallmark-redesign-review
description: "Use to review a built page's hero or finish in fresh context, or audit/redesign an existing site"
---

# Hallmark redesign and review

Two jobs that need a reader who did not build the page: (1) fresh-context reviews of a page you built (hero review mid-build, finish review at the end); (2) auditing or redesigning an existing site while keeping its content and wiring. Complements `hallmark-design-direction` (the gates and catalogues) and `ui-design` (critique/audit/polish playbooks); no CLI is needed.

## Reviews (fresh context)

The thread that built the page is its weakest reviewer. Start a fresh-context subagent per review with no inherited transcript; pass files as paths and facts as quoted text; run it in the foreground. If no subagent is available, re-read the artifact cold and run the prompt against yourself, saying "in-thread".

- **Hero review**, once, before any section below the fold exists. Inputs: screenshots of the first screen (375, 1280x800, 1440x900, 1920x1080), the declared theme/idea, the material and signature lines. Output: first line `ship` or `fix`, then at most five one-line findings, worst first. Ask: does the headline say something only this product could, in seven words or fewer? Is content centred in the screen (no dead band) with a real picture (user's, photograph, the built product) beside the text holding at least 60% of its half? Anything template-like (centred stack, pill/label above the headline, gradient blob, empty coloured box, drawn illustration, counting marks, two filled buttons side by side)? Is the signature on this screen (delete the picture in your head: does the screen still say the same)? Does the type carry the theme? Custom run: skip the centred questions, ask "would a model make this for this prompt, and what gives it away?".
- **Finish review** at the end. Inputs: screenshots (folds at 1280x800, 1440x900, 1920x1080; full page at 1440 and 375), the page source, the theme/idea line, the hero review's findings with how each was settled, and the gates in `hallmark-design-direction`. First line: `recapture` (a screenshot is blank or wrong; list which, stop), `rebuild` (first viewport fails the idea wholesale), `fix`, or `ship`. Then at most eight findings ranked by cost, one line each: gate or plain defect, where, what to do. Not findings: a direction the reviewer would not have chosen; what the theme prescribes. Scroll the 1440 full page one screen at a time first: a screen with nothing big enough to be its reason outranks every detail finding. Then name any head that would pass unchanged on a competitor's page. Then one answer: does the stated idea describe the page? Name the largest gap. Close with one line on what must not be diluted while fixing.
- Custom run extras: two lines of the reviewer's own (what the page is about; what a visitor would remember), then findings for Seen-before (reads as a template/catalogue/familiar site), Clean (something without a job), Carried (the idea lives only in the hero).
- App screen: no hero or fold; ask hierarchy, even density, whether tables and controls work on a phone, whether the states exist.
- Acting on the result: `recapture` does not use up the round. Fix what is real, recapture the same shots, and mark each finding resolved / partial / unresolved with a reason. Send recaptures back for one scoring round only after `rebuild` or a Floor-gate finding. Nothing ships with an open Floor failure; a Reflex finding is fixed or waived with a reason; Finish findings are answered.

## Redesign and audit (existing sites)

Run only when the user asks for a redesign or audit explicitly. Details, depths and the handoff format: `references/redesign-protocol.md`.
1. Pre-flight: read the project, list pages (route, file, page vs app screen), record the current state with screenshots at 375 and 1440 before touching anything. In a git project ask the user to commit or stash first; never do it for them.
2. Give the read in four lines: what the page is for, what works and stays, what reads as generated (by gate), what is broken.
3. **audit** stops here: report findings by tier with `file:line`, the lightest depth that settles them, and change no files.
4. **redesign** keeps content and wiring. Choose a depth: full (system and composition change), restyle (layout kept, tokens change), polish (only what a gate names). Name the depth and a file-level plan (edit / create / delete) and get the user's approval before deleting or replacing any file.
5. After: compare against the record (links, forms, fields, handlers, test hooks, scripts, headings, figures), run the project's own type check, build and tests, and give a handoff (kept, changed, dropped with reasons, claims carried over for the owner to verify).

## References

- `references/redesign-protocol.md`: load when starting a redesign or audit.
- `references/gates.md` and `references/gates-finish-judged.md` of the `hallmark-design-direction` skill (install both skills together): load for the gate list the reviewers judge against.

Attribution: distilled from https://github.com/Nutlope/hallmark (MIT). See `SOURCES.md`.
