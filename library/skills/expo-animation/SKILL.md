---
name: expo-animation
description: "Use for React Native/Expo animation: gestures, sheets, press feedback, haptics, transitions, device jank"
---

# Animation in React Native and Expo

Turn a request for motion into an implementation that holds up on a real device. Mobile changes three things: no hover (affordances live in press or position), two runtimes (RN/JS runtime vs the UI runtime where worklets run each frame; keep motion on the UI runtime), and the finger is on the element (interruptibility and velocity handoff are baseline).

Make the call, state the reason in one line, write the code. Failure modes, worst first: (1) animating something that should not animate (producing zero lines is a valid result); (2) right animation, wrong thread (`setState` per frame, `PanResponder`, animated `height`): fine in dev, 20fps on an old Android.

## Rules

1. Follow the sequence below in order; steps 1-2 gate everything.
2. Reanimated, not core `Animated` (it cannot run gesture logic on the UI thread and its native driver only does transform and opacity).
3. Curves and springs come from the tables here; do not invent values.
4. Reduced motion ships with the animation.
5. Feel is judged on a release build on the slowest supported device, never Expo Go or the simulator.
6. Ask the user before installing dependencies; use SDK-matched versions (Expo's own install command resolves them) and tell the user what you added.

## Sequence

1. **Frequency gate.** 100+/day (tab switches, keyboard open/close, scrolling, settings toggles): no animation, platform default. Tens/day (press, row selection): under 150ms or nothing. Occasional (sheets, modals, toasts, onboarding steps): standard. Rare/first-time: the delight budget. Tabs never slide (peers, not hierarchy): `animation: 'none'`.
2. **Name the purpose**: feedback, spatial consistency, state indication, preventing a jarring change, explanation, delight (rare tier only). Cannot name it: do not build it.
3. **Cheapest tool**: state change without a gesture -> Reanimated CSS transition (`transitionProperty` in style); loop/multi-stage/mount -> CSS animation keyframes; mount/unmount/reflow -> layout animations (`entering`/`exiting`/`itemLayoutAnimation`); anything a finger touches or scroll-derived -> shared value + `Gesture` + `useAnimatedStyle`; screen to screen -> Expo Router native stack options (never hand-roll); self-contained bottom sheet -> `presentation: 'formSheet'`; tab bar -> native tabs; context menu/peek -> native `Link.Menu`/`Link.Preview` (iOS); collapsing large title -> `headerLargeTitleEnabled` (iOS); pull to refresh -> `RefreshControl`; keyboard-tracking UI -> `react-native-keyboard-controller`; illustration -> Lottie (never UI state); huge scenes -> Skia. A shared value is for continuous or interruptible values only; a two-state toggle is a CSS transition.
4. **Properties.** `transform` and `opacity` are free; `width/height/margin/padding/flex/top/left/gap` re-run layout for the node and siblings every frame. Sole exception: an absolutely positioned childless element (tab pill, progress fill) where `scaleX` would smear corners. Never `scale(0)`: start at 0.9-0.97 plus opacity 0. Transform arrays are ordered (translate first). Never animate Android `elevation` or `BlurView` intensity (crossfade a static layer). Percent `translate` is relative to own size.
5. **Timing or spring.** Finger dragging/flinging/releasing: spring. Press feedback: timing. Springs use Apple-style params `{ duration, dampingRatio }`: default settle `{400, 1}`; snap back after drag `{400, 0.8, velocity}`; sheet/drawer `{300, 0.8, velocity}`; add `overshootClamping: true` at hard edges. Bounce only when the gesture carried momentum. Easing for non-gesture motion: enter/exit ease-out, on-screen movement ease-in-out, constant linear; never ease-in. Use `Easing.bezier(0.23,1,0.32,1)` (ease-out), `(0.77,0,0.175,1)` (in-out), `(0.32,0.72,0,1)` (sheet). Durations: press 100-150ms, toggle/chip 150-200ms, sheet about 300ms perceived, screen transition = platform default. UI stays under 300ms; beat the platform everywhere except navigation.
6. **Keep off the JS thread.** No `setState` in gesture/scroll handlers. Do not call back to the RN runtime per frame (`scheduleOnRN` from `react-native-worklets`, replacing deprecated `runOnJS`) inside `onUpdate`/scroll; do it in `onEnd` or in `useAnimatedReaction` at a threshold. Never read or write a shared value during render; use `.get()`/`.set()` (compiler-safe) in worklets, handlers, effects. Functions called from worklets need the `'worklet'` directive.
7. **Press, not hover.** Feedback on press-in, commit on press-out; scale 0.97 over 100-150ms; 44x44pt (48dp) minimum target via `hitSlop` not visual growth; `pressRetentionOffset` so drift does not cancel; no ripple unless the app is Material-styled.
8. **Haptics.** Selection tick for steps/detents (`selectionAsync`); light impact for snap/commit; medium for heavy landing or destructive; notification success/error for outcomes. Same frame as the visual, fired at the causal moment; one per semantic event; never per frame or on scroll; never the only feedback (off for many users, silent on most Android). From a worklet use `scheduleOnRN`.
9. **Reduced motion.** `useReducedMotion()` or per-animation `reduceMotion: ReduceMotion.System`: keep opacity/color, drop translation/scale/parallax/overshoot; screen transitions become `'fade'`. Text scales: never animate to a hardcoded height; measure with `onLayout` or animate a transform.

## Setup that silently breaks motion

Wrong versions (install via Expo so they match the SDK); `GestureHandlerRootView` missing at the root (gestures do nothing, no error); Reanimated 4 needs the New Architecture; bare RN needs the worklets Babel plugin last (Expo's preset does it); ProMotion iPhones cap third-party animation at 60fps unless `CADisableMinimumFrameDurationOnPhone` is true (recent SDKs set it; verify). Judge on a release build.

## Never ship

`PanResponder`; `setState` in gesture/scroll handlers; `runOnJS` (use `scheduleOnRN`); per-frame `scheduleOnRN`; shared values touched during render; core `Animated` for touch-driven motion; animating layout props; `entering` on rows of virtualized lists (recycling re-fires it: animate the container or use `itemLayoutAnimation`); JS-rebuilt screen transitions; sliding tabs; `Easing.in`; `scale(0)`; distance-only dismissal; hard stops at edges (rubber-band); a haptic per frame or as sole feedback; verifying in Expo Go.

## Output

The code, then at most a few lines: gate result and purpose (and anything rejected); ingredients (tool, properties, spring/curve plus duration, thread); on-device feel checks (flick, interrupt mid-flight, reverse, slowest Android).

## References

- `references/gesture-recipes.md`: load when writing a draggable sheet, swipe-to-delete, collapsing header, or threshold-fired haptic/reaction, or needing the `project`/`rubberband` worklets and Gesture Handler v3 notes.
- `references/ui-recipes.md`: load when writing press feedback, list entrances, keyboard-synced UI, tab indicator, screen/sheet transitions or a toast.

Provenance: see `SOURCES.md`.
