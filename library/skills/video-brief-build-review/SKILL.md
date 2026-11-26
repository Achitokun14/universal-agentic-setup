---
name: video-brief-build-review
description: "Use for programmatic motion-graphics or launch videos: spec first, build from code, review, then render."
---

# Video: brief, build, review

Purpose: make code-built videos without rebuilding the whole timeline after every wrong guess. Separate creative decisions (brief) from code (build) from critique (review). Render once, at the end.

## Rules
1. Never build from a vague idea. No scene code is written until `video/video.md` and approved preview stills exist.
2. Never render the video file during build or review. Preview the live scene code (in a browser, via the agent's browser automation if available) and contact-sheet stills. Rendering the final file needs explicit user approval.
3. Run the slop precheck (stage 0) before the brief and again before review.
4. Keep every stage's output as plain files under `video/` in the project, so a fresh context can pick up from disk.

## Stage 0: slop precheck
Read `references/ai-video-tells.md`. Treat it as a ban list: nothing on it may appear in `video.md`, the stills or the scene code.

## Stage 1: brief (creative discovery, no animation code)
1. Ask which intake mode the user wants; default to mode 2.
   - Mode 1, detailed control: interview on palette, typography, camera/motion choreography, aspect ratio, duration, feature callouts.
   - Mode 2, general direction: ask only subject, audience, visual reference style, duration, orientation, key features. Resolve secondary choreography yourself and say what you chose.
   - Mode 3, autonomous: one topic sentence in; you make every design, pacing and storyboard decision and list them.
2. If the project has a repo, pull real brand colors, fonts and copy from it instead of inventing them.
3. Pick the music first (code-synthesised track, or the user's file with timestamps mapped to it). Record tempo and beat grid; scene cuts are placed on beats.
4. Write `video/video.md` (template below).
5. Make 2-3 preview stills (HTML or canvas): opening shot, mid-action peak, closing frame. Show them to the user and wait for approval or changes. Revise stills, not code.

### `video.md` must be self-contained
A new context with no chat history must be able to build from it with zero questions. Include:
- Goal, audience, aspect ratio, duration, fps, music file/tempo/beat times.
- Design tokens: palette (hex), fonts and sizes, spacing, easing curves and durations.
- Scene list: for each scene, start/end time, what is on screen, what moves, camera motion, text copy verbatim, which beat it cuts on.
- Assets: every file path or generated asset, with how it is produced.
- Banned items carried over from the ban list; open decisions (should be none).

## Stage 2: build (fresh context, code only)
1. Start from a fresh context: new session, or a builder subagent (if available) whose assignment says "build strictly from `video/video.md` and the files in `video/`". Do not carry the interview over.
2. Write components, scene timeline and audio wiring from the spec. If the spec is ambiguous, stop and list the gap for the user; do not guess.
3. Do not render. Verify only that the preview plays and scene times match `video.md`.

## Stage 3: review
1. Capture one frame per second across the runtime and tile them into one contact-sheet image (use browser automation to step the live preview and screenshot each second, or ffmpeg to sample frames from an existing preview recording, then tile them). Read the sheet in one pass for pacing stalls, empty stretches, clipping, overcrowding, broken transitions, and any ban-list item.
2. Collect user notes pinned to timestamps (for example `0:07 headline too small`). Convert each to a scene id using the scene list.
3. Batch notes by scene so each scene is edited once per round.
4. Route each scene's batch:
   - Small edits (copy, millisecond timing, colors, offsets): a subagent on a cheaper model tier (if available), run in parallel across scenes. Brief it with the exact notes and tell it not to change creative direction.
   - Structural edits (choreography, layout, reordering, new elements): the strongest tier available, or you directly.
5. Re-preview, regenerate the contact sheet, repeat from step 1 until the user is happy.
6. Optional zero-context pass: start a fresh read-only subagent or session, give it only the contact sheet and `video.md`, and have it list problems. Allow up to 3 revision loops, then show the user what remains.

## Stage 4: final render
Only after the user explicitly says to render. State the output path and settings, render once, then check loudness (see launch rules) and open the result for the user.

## Launch-film rules
Apply when the video promotes a product. Details in `references/launch-film-rules.md`.

## Complements
Remotion API specifics live in the `remotion-best-practices` skill; footage editing, Playwright screen recordings and repo-to-launch-video flows live in separate skills (each if installed). This skill is only the spec/build/review process around them.

## References
- `references/ai-video-tells.md`: load when writing the brief, building scenes, or reviewing a contact sheet.
- `references/launch-film-rules.md`: load when the video is a product launch, social reel or promo.
- `references/clone-motion-loop.md`: load when the user wants an existing web animation, video or GIF reproduced in their own stack.
