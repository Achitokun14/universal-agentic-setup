---
name: gesture-driven-ui
description: "Use for web drag, swipe, sheet or hold gestures that lag the pointer, jump on release, or can't be caught"
---

# Gesture-driven UI (web)

Direct manipulation: while the pointer is down the UI IS the pointer; once it lifts, physics finishes the motion. Most "feels wrong" gestures mix up these two phases.

## Decide first: build or use a component

A correct bottom sheet/drawer needs momentum dragging, overlay opacity tied to progress, velocity-aware dismissal, focus trapping and Escape-to-close: weeks of edge cases. Default to Vaul for drawers; hand-roll only for bespoke interactions (swipe cards, custom drag). Check `package.json` before adding any dependency and ask the user before installing.

## Two phases

```
pointer down? -> TRACK: position = pointer, 1:1. No easing, duration or spring.
pointer up?   -> RELEASE: spring seeded with release velocity (or CSS transition for CSS-only components). Never a keyframe.
```

### Track rules
- 1:1 means 1:1: drive from a motion value or direct `transform` writes; a spring during tracking makes the element trail the finger.
- Respect the grab offset (where on the element the user grabbed); never snap its center to the pointer.
- Write `transform` directly on the dragged element. Never push the drag distance through a CSS variable on a parent: it is inherited, so every descendant restyles each move (this made Vaul lag past ~20 items).
- No React state per move event; use motion values or direct style writes.
- Pointer Events with `setPointerCapture`; keep a short history of position and timestamps to compute velocity; ignore additional touch points once a drag has started.
- Declare intent first: ~10px hysteresis before committing to an axis, then track. Run all plausible recognizers in parallel and cancel losers; do not rely on final-state events (swipeleft-style).
- Rubber-band past edges (Motion `dragElastic` about 0.2): progressive resistance, never a hard stop or invisible wall.

### Release rules
- Custom drags settle with a spring seeded with the gesture velocity (Motion `velocity` option takes px/s). Fixed-duration easing makes every fling land identically.
- Dismiss on distance OR velocity: about 40-50% of travel, or a flick (`abs(distance)/elapsedMs > ~0.11`). Distance-only makes flicks feel ignored.
- Better still, project where the flick was going (`position + (v/1000)*0.998/(1-0.998)`) and snap to the nearest point to that projection.
- Bounce (0.1-0.3) only when the gesture carried force. The same element closed by a button gets zero bounce. Smaller elements need more bounce to read the same.
- Snap-back after a failed threshold is fast, never slow.

## Interruptibility (non-negotiable)

The user can catch a closing sheet and drag it back. Start every new animation from the live on-screen value, not the target; springs carry velocity through retargeting; keyframes restart from zero. Never put a `@keyframes` animation on anything a gesture can touch. Never lock input during a transition. Animate X and Y as independent springs.

## Linked values

Derive companions from one source of truth: overlay opacity = `useTransform(y, [0, height], [1, 0])`; page scale likewise. Separate animations drift apart as soon as the gesture is interrupted.

## CSS-only sheets (Vaul style)

Edge-attached sheet: `cubic-bezier(0.32, 0.72, 0, 1)` over 500ms (steep start, so it feels snappy and settles gently). A small floating drawer: about 200ms with `cubic-bezier(0.165, 0.84, 0.44, 1)` on both drawer and overlay. The component must feel like one entity: height changes and content crossfades share its timing family. Mark interactive children `data-vaul-no-drag`.

## Spatial consistency and holds

- Dismiss along the axis the element entered on (toast enters from the bottom, swipe down dismisses); anchor popovers to their trigger.
- Hold-to-confirm: `linear` during the hold (the fill visualizes time), snap back with `ease-out` about 200ms on early release. Symmetric timing here is a bug.

## Touch checklist

Test on a real phone via the dev server's LAN IP (trackpad emulation lies; 120Hz exposes roughness 60Hz hides). Hit targets at least 44x44px (enlarge via an invisible `::before`). `touch-action` set to what the browser may still do (`pan-y` for a horizontal carousel, `pan-x` for a vertical sheet, `none` only on surfaces that own every axis). Press feedback on pointer-down, commit on pointer-up. Gate hover with `@media (hover: hover) and (pointer: fine)`.

## Reduced motion

Tracking stays (the user produces it). Drop momentum flings, bounce and decorative motion; settle with a short opacity/position change.

## Troubleshooting

"Weird" spring: raise damping first. Stutter is a performance bug: check the track rules, then the frame-budget guidance in the `ui-design` skill (if installed): animate only `transform` and `opacity`, avoid layout work per frame. Unnameable feeling: record and scrub frame by frame.

## References

- `references/web-recipes.md`: load when writing Motion drag props, a pointer-event drag with velocity history, momentum projection or rubber-band helpers, or hold-to-confirm.

Provenance: see `SOURCES.md`.
