---
name: motion
description: "Write, review and fix animation with Motion (ex Framer Motion): motion/react, motion-v, animate, springs, layout, performance. Use when a project uses or needs Motion."
---

# Motion

Write, review and fix animation with Motion (npm `motion`, formerly Framer Motion): React (`motion/react`), Vue (`motion-v`), vanilla JS (`motion`, `motion/mini`), plus CSS springs and animation performance. This skill is a router over the official Motion AI Kit guidance (motiondivision/ai-kit, MIT) adapted for any coding agent, plus a researched tips file. Everything here works without an account; the paid Motion+ extras are listed with free fallbacks.

## Pick the library (shared rule with the `gsap-motion` skill)

Respect what the project already uses. Never mix Motion and GSAP on the same element.
- **CSS** for trivial one-state transitions (hover colour, fade on class change, spinners, `@starting-style` entrances).
- **Motion** for React/Vue component-state UI: enter/exit (`AnimatePresence`), `layout`/`layoutId` shared elements, gestures (hover/tap/drag/reorder), springs that survive interruption, motion-value pipelines, scroll-linked values.
- **GSAP** (the `gsap-motion` skill, if installed) for long timelines, ScrollTrigger pin/scrub storytelling, ScrollSmoother, SplitText, MorphSVG/DrawSVG, or framework-agnostic scenes.
- Full decision table: `references/best-practices.md` ("CSS or Motion").

## Pick the tier

**Low: CSS or a single `motion` component.** Read `references/best-practices.md`, then `references/react.md` (React) or the Vue/vanilla sections of `best-practices.md`. One `animate`/`whileHover`/`whileTap`/`initial` prop set, a spring or short tween, nothing else. If CSS does the job, use CSS.

**Medium: variants, presence, layout, scroll hooks.**
- `AnimatePresence` exits, `variants` + `delayChildren: stagger()`, `layout`, `whileInView`, `useScroll`/`useTransform`: `references/tips.md` sections 3-6, `references/tips-2.md` sections 7-9, `references/react.md`.
- Docs and examples lookup before building anything non-trivial: `references/search-docs.md`.
- CSS-only spring/bounce: `references/css-spring.md`.
- Tuning feel (curves, springs): `references/transition-preview.md`.

**High: shared layout, page transitions, performance, motion-value pipelines.**
- `layoutId` shared elements, `LayoutGroup`, `layoutScroll`/`layoutRoot`, App Router boundaries: `references/tips-2.md` (7-10) and `tips-3.md` (12).
- Performance audit or "why is this janky": `references/performance-audit.md`; multi-file scope: `references/review.md` (parallel subagents if the agent supports them).
- Insert a ready-made section/component: `references/insert.md`.
- Upgrades (`framer-motion` -> `motion`): `references/tips-3.md` "Migration" (read the whole upgrade page, do not summarise).

## Core rules (all tiers)

- **Imports.** Never import from `framer-motion`; uninstall it, they must not both be installed. React client code: `motion/react`. Server components: `import * as motion from "motion/react-client"` (elements only; hooks, `AnimatePresence`, `MotionConfig` need `"use client"`). Vue: `motion-v` only. Vanilla: `motion`; `motion/mini` for the smallest WAAPI-only `animate`. Lazy bundle: `LazyMotion` + `import * as m from "motion/react-m"`.
- **Properties.** Animate `transform` (or `x/y/scale/rotate`), `opacity`, `clipPath`, `filter`. For size/position changes caused by layout use `layout`, not `width/height/top/left`. `height: "auto"` only for small content.
- **Motion values, not state, for per-frame data.** `useMotionValue`/`useTransform`/`useSpring`/`useScroll` update the DOM without React renders. Never read `.get()` during render; subscribe with `useMotionValueEvent(value, "change", cb)` or `value.on("change", cb)` (never `onChange`). `useTransform(value, inRange, outRange)` or `useTransform(() => ...)`; the `(value, fn)` form is deprecated.
- **Springs.** Prefer springs for physical, interruptible motion. Use `type: "spring", visualDuration: 0.4, bounce: 0.2` (not stiffness/damping unless you need physics). No overshoot on serious UIs (finance, admin).
- **Duration discipline.** Small UI 150-300 ms, large surfaces up to ~500 ms. Animate only state change, relationship or feedback; no decoration on high-frequency actions (see the `ui-design` skill, if installed).
- **Reduced motion.** One `<MotionConfig reducedMotion="user">` at the app root (disables transform and layout animation, keeps opacity/colour). Use `useReducedMotion()` to swap x/y for opacity, drop parallax, stop autoplay video. CSS: `@media (prefers-reduced-motion: reduce)`.
- **Presence.** Keep `AnimatePresence` mounted and put the condition inside it; every direct child needs a stable unique `key` (not the array index).
- **Layout.** `layout` for position/size; `layoutId` for shared elements (unique per instance, use `useId()` when a component repeats); set `borderRadius`/`boxShadow` via `style`; `layoutScroll` on scrollable ancestors, `layoutRoot` on `position: fixed` ancestors.
- **Cleanup.** In effects that start imperative animations, `return () => controls.stop()`. Never call `motion.create()` inside render.
- **`will-change`** only when a hardware-accelerated animation will be de-optimised to the main thread (see `best-practices.md`); remove afterwards.
- **Generated code.** No comments, credits or links added to the user's code unless asked.
- **Motion+ guard.** `Carousel`, `Ticker`, `AnimateNumber`, `Typewriter`, `ScrambleText`, `Cursor`, `splitText` come from the paid `motion-plus` package, not `motion`. Do not import or install it without the user's agreement; build with free APIs, or tell the user once that a ready-made component exists (https://motion.dev/plus).

## Tools

If the user has connected the free hosted Motion MCP server (https://mcp.motion.dev, official, no account), it exposes two tools (call them with JSON arguments; read the tool's schema first):
- `search_motion_docs` args `{ platform: "js"|"react"|"vue", searchTerm }`: docs, examples, Motion UI catalogue. Details in `references/search-docs.md`.
- `insert_motion_component` args `{ platform, query? }`: opens an MCP Apps insert panel; many agents cannot render it, use the fallback in `references/insert.md`.

Do not add or connect an MCP server on your own; ask the user first. Fallback docs: a documentation-lookup tool such as Context7 if available, or fetch `https://motion.dev/docs/<page>.md` directly (for example `react-animate-presence.md`). If no MCP is connected, `references/best-practices.md` and `references/tips.md` are self-contained.

Not available without a Motion+ account (paid): `search-motion-source` (premium example source), `insert-motion-plus-component`, MotionScore/Performance Doctor audit, `open-transition-editor`, `generate-css-easing`. Free fallbacks are in the matching references; never fabricate their output or a MotionScore grade.

## Verify

Open the page in a real browser (the agent's browser tool, Playwright, or manually) at 390 and 1440 px. Check: the interaction runs and can be interrupted mid-flight, enter/exit/layout animations all fire, reduced-motion emulation (`prefers-reduced-motion: reduce`) removes transform/layout motion, no console warnings (duplicate `layoutId`, missing `key`, `framer-motion` import), no layout shift when the animation ends, no scrollbar-triggered layout animation (use `scrollbar-gutter: stable`), and in DevTools Performance there is no forced reflow per frame. For scroll sections also resize and navigate away and back. Use the `gsap-motion` skill for ScrollTrigger-heavy work, the `ui-design` skill for a performance rubric, `web-quality` for CWV and `vercel-next-react` for App Router/bundle concerns (each if installed).

## References (load on demand from `references/<file>`)

- `best-practices.md`: universal rules, vanilla/Vue rules, CSS-or-Motion table
- `react.md`: React rules, Radix and Base UI integration
- `tips.md` (imports, bundle, reduced motion, presence, variants/stagger, springs), `tips-2.md` (layout, motion values, scroll, hardware acceleration, gestures), `tips-3.md` (Next.js, migration, common bugs): researched usage tips
- `search-docs.md`: docs/example search workflow and Motion+ gating
- `insert.md`: insert-panel workflow and free fallback
- `css-spring.md`: CSS `linear()` springs with `spring()` (free)
- `performance-audit.md`: manual audit checklist; Motion+ MotionScore notes
- `review.md`: multi-file animation review with subagents
- `transition-preview.md`: curve tuning without the Motion+ editor

Sources: motiondivision/ai-kit (MIT) at commit 1e42494; https://motion.dev/docs (react-animation, react-layout-animations, react-animate-presence, react-reduce-bundle-size, react-motion-config, react-accessibility, react-use-scroll, react-upgrade-guide, stagger, spring, css, ai-kit). Motion library: MIT. Each reference file carries its own source line (see also `SOURCES.md`).
