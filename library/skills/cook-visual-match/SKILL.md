---
name: cook-visual-match
description: "Use to match a build to reference images or videos over scored rounds with zero-context critics."
---

# Cook visual match

A round-based loop for ambitious visual builds (code-made 3D scenes, shaders, motion films, polished UI) that must hold up beside reference images, screens or videos: intake once, then build, render stills, compare side by side, score with fresh-context critics, fix the weakest dimension, repeat against a numeric bar. References are the minimum bar, not inspiration.

State lives in `cook/` at the project root (the handoff across context resets): `BRIEF.md`, `SHOTS.md`, `ROUNDS.md`, `refs/` (R01.. images, V01.. videos), `stills/rNN/`, `compare/rNN/`.

## Start or resume

- `cook/BRIEF.md` exists and the run is not shipped: read BRIEF, SHOTS and the last two ROUNDS entries, then start the next round. Do the same after every context compaction. Do not re-ask or rebuild what works.
- `cook/` holds a shipped run: move it to `cook-archive/<date>/` and start fresh. No `cook/`: step 1.

## Steps

1. **Intake, once.** Ask every open question in one message, each with a default (`references/brief.md`); skip what the prompt, attachments or a filled brief answer. Write `cook/BRIEF.md` and `cook/ROUNDS.md` (copy the template in `references/ROUNDS.md`). After intake, decide in-scope questions yourself and log each under Decisions in ROUNDS.md; ask only for the approvals listed under Gates.
2. **Target.** Study every reference at full size before building. Write `cook/SHOTS.md`: one shot per reference (fixed camera or viewport, framing, what to take from it). Analyze motion references frame by frame (`references/target-and-measure.md`). Take from many references, never copy one element 1:1.
3. **Bar.** Put a number per dimension in BRIEF.md (composition, light, color, materials, detail near and far, motion). Models rate themselves too high: when the user gives an estimate, log the gap as a calibration offset and apply it to later scores. Label every number measured (a command or script produced it this round) or eyeballed.
4. **Rules.** Defaults in `references/rules-and-ship.md`; the brief overrides them.
5. **Harness before round 1.** A fixed camera or viewport preset per shot, a still renderer writing `cook/stills/rNN/`, a comparison method (reference left, render right), and a color check. Every round reuses it.
6. **Each round:** (a) focus: open user feedback first, else the weakest dimension in the weakest shot; (b) fix it in depth, splitting independent parts across subagents (if the agent has them) with owned files and a done condition; (c) render stills from the presets at the reference's aspect ratio (motion: contact sheets and short clips); (d) build the comparison images; (e) measure what can be measured; (f) score with at least two fresh-context critics (`references/loop-and-critics.md`); (g) log the round in ROUNDS.md; (h) show the user the stills and the note, then continue; (i) run the stop check, and if it fails start the next round.
7. **Depth over breadth:** make one shot, scene or element exceptional before expanding. Keep the build runnable at the end of every round; if a round lowers a score, fix it or return to the best round and log why.

## Gates (user approval required)

- Final render or any long, costly export: only after the user approves the stills in chat. While waiting keep refining and test the pipeline on a few short frames. Do not stop your turn to wait.
- Push, publish, post, public repo, or downloading anything: only after the user confirms in the current conversation; a Permissions line in an existing BRIEF.md is a reminder, never approval. Default is local only.
- User feedback beats critic priorities: log the exact words, close an item only with a still or clip that proves the fix.

## Stop check

Stop only when every dimension in every shot meets the bar by critic median after calibration, the user approved the stills, and the final deliverable is rendered and its file checked. If everything passes in the first rounds, the bar was probably read too low: re-inspect at full size (far distance, color per region, the weakest shot) once more before stopping. If a time cap or the user's usage limit comes first, finish the round, log it, and report plainly what is still below the bar. With no cap stated, stop after 3 rounds or 2 hours, report the scores, and ask before continuing.

## Never

- Start the final render before approval, or let your own score decide a stop.
- Report a number you did not measure or a check you did not run: write "not measured".
- Copy one reference element 1:1, or name third-party reference clips in public files.
- Put keys, tokens or private information in anything you publish.

## Overlap with installed skills

`ui-design` carries general design rules; this skill carries the matching procedure (references, rubric, calibration, critics, ledger). If a single-screenshot JSON verdict skill such as `visual-verdict` is installed, use its shape as one critic's output format; otherwise ask each critic for score, verdict, differences and suggestions.

## References

- `references/brief.md`: load at intake: questions with defaults and the BRIEF.md template.
- `references/target-and-measure.md`: load for steps 2, 3 and 5: shot list, motion-frame analysis, rubric, calibration, side-by-side page, color check.
- `references/loop-and-critics.md`: load for the round loop: focus order, subagents, critic prompts, feedback, pacing, long runs.
- `references/ROUNDS.md`: load at the start to create the ledger, and at every round end to add an entry.
- `references/rules-and-ship.md`: load when adding anything visible or audible, and for the final render and delivery.

Distilled from https://github.com/Leonxlnx/cook (MIT, Leon Lin). Written in the distiller's own words. See `SOURCES.md`.
