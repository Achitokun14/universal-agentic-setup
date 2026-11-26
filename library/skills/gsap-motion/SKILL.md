---
name: gsap-motion
description: "Write, review and fix GSAP animation: tweens, timelines, ScrollTrigger, plugins, framework cleanup, performance. Use when the task involves GSAP or scroll-driven animation."
---

# GSAP motion

Write, review and fix GSAP code: tweens, staggers, timelines, ScrollTrigger (scrub, pin, parallax), plugins (Flip, Draggable, ScrollSmoother, SplitText, DrawSVG, MorphSVG...), `gsap.utils`, framework lifecycles and performance. This skill is a router over the official GreenSock agent skills (greensock/gsap-skills, MIT; text kept close to the originals; the upstream `gsap-scrolltrigger` skill is merged into `references/scrolltrigger.md`; see `SOURCES.md`).

**License (verify before shipping commercially).** I checked https://gsap.com/community/standard-license/ (effective 2025-04-30): the Standard "No Charge" license allows commercial use of GSAP and all plugins, including formerly paid SplitText and MorphSVG, with no key or token; everything installs from the public `gsap` npm package. The one prohibition: using GSAP inside a no-code visual animation builder that competes with Webflow's. AI-generated GSAP code is explicitly allowed. Terms can change: re-read that page for the shipping context (especially if the product is a visual animation tool) and tell the user if anything looks borderline. Never generate an `.npmrc` with a GreenSock token or point at the old private registry.

## Pick the tier

**Low: a single tween, stagger, or fade-in.** Load `references/core.md` (+ `core-2.md` for transforms, easing, stagger). Use `gsap.to/from/fromTo/set`; camelCase props; transform aliases (`x`, `y`, `scale`, `rotation`, `xPercent`); `autoAlpha` over `opacity`; string eases. For a trivial hover or one-shot fade where no runtime control is needed, plain CSS is fine (see `core.md` "Prefer GSAP Instead of CSS Animations When").

**Medium: sequences, scroll animation, framework cleanup.**
- Install and imports (npm, ESM, one `gsap.js` registry module, plugin prerequisites, TypeScript, SSR, dev-only plugins): `references/install-esm.md`.
- Sequencing: `references/timeline.md` (position parameter, labels, defaults, nesting).
- Scroll: `references/scrolltrigger.md` (config, batch, scrollerProxy, scrub, pin, horizontal scroll via containerAnimation, refresh, cleanup, do-nots).
- React/Next.js: `references/react.md` (`useGSAP`, scope, `contextSafe`, SSR). Vue/Nuxt/Svelte/SvelteKit: `references/frameworks.md`, `frameworks-2.md`, `frameworks-3.md`. Astro: use the same mount/scope/revert principles (frameworks.md "Principles") inside a client script or component, and reinitialize on view-transition navigation (`astro:page-load`) with cleanup on `astro:before-swap`; the Astro event names are from memory (not in the official GSAP text), so confirm them in current Astro docs through the `astro-svelte` skill.

**High: plugins, performance budget, cross-framework refactor.**
- Plugins and licensing: `references/plugins.md` .. `plugins-5.md` (Scroll: ScrollToPlugin, ScrollSmoother; UI: Flip, Draggable, Inertia, Observer; Text: SplitText, ScrambleText; SVG: DrawSVG, MorphSVG, MotionPath; easing: CustomEase, EasePack, CustomWiggle, CustomBounce; physics; GSDevTools; Pixi).
- Tips, tricks and gotchas (quickTo, overwrite, easeReverse, matchMedia/reduced motion, ScrollTrigger tuning, normalizeScroll, Lenis sync; ScrollSmoother setup, SplitText autoSplit, Flip, Draggable+Inertia, Observer, DrawSVG/MorphSVG, GSDevTools, mistakes checklist): `references/tips.md`, `references/tips-2.md`.
- Helpers: `references/utils.md`, `utils-2.md`, `utils-3.md` (`clamp`, `mapRange`, `normalize`, `interpolate`, `random`, `snap`, `distribute`, `toArray`, `wrap`, `pipe`).
- Performance and jank: `references/performance.md`; pair with the `ui-design` skill (if installed) for animation-performance and design-engineering guidance (frequency gate, easing, duration, reduced motion, craft).
- Large refactors: do it per file; use the agent's structural code-search/rewrite feature if available, otherwise `grep`, to find every `gsap.` call site, then add scope and revert to each.

## Core rules (all tiers)

- Register every plugin once before use: `gsap.registerPlugin(ScrollTrigger, ...)`. Import plugins from `gsap/<Plugin>` (the single public package; eases RoughEase/ExpoScaleEase/SlowMo come from `gsap/EasePack`); register once in a shared `gsap.js` module (`install-esm.md`). CustomBounce/CustomWiggle need CustomEase, ScrollSmoother needs ScrollTrigger, Draggable `inertia` needs InertiaPlugin; keep GSDevTools/MotionPathHelper out of production.
- **Timelines, not `delay` chains**, for sequences; set shared `defaults` on the timeline; place tweens with the position parameter or labels.
- **ScrollTrigger goes on the top-level tween or the timeline, never on a child tween** inside a timeline; use `scrub` or `toggleActions`, not both; `ease: "none"` on a `containerAnimation` horizontal tween; call `ScrollTrigger.refresh()` after layout changes (content, images, fonts); set `refreshPriority` if you create triggers out of page order; remove `markers: true` before shipping.
- **Cleanup is mandatory in components.** React: `useGSAP()` with a `scope` ref (or `gsap.context()` plus `ctx.revert()` in the effect cleanup), `contextSafe` for handlers created later, no gsap/ScrollTrigger calls during SSR. Vue/Svelte: create after mount, scope selectors to the root, `ctx.revert()` on unmount.
- **Never target by a bare selector without a scope** inside a component.
- **Responsive and reduced motion:** use `gsap.matchMedia()` for breakpoints and `(prefers-reduced-motion: reduce)`; reduce or skip animation when it matches (do not nest `gsap.context()` in it; call `mm.revert()`).
- **Performance:** animate transforms and opacity; avoid width/height/top/left; use `stagger` instead of many manual-delay tweens; `gsap.quickTo()` for mouse followers; `will-change` only on elements that animate; pin only what is needed; pause or kill off-screen animations.
- Multiple `from()`/`fromTo()` on one property of one element: set `immediateRender: false` on the later ones.
- Respect the project: if it already uses another motion library (CSS, Motion/Framer), do not add GSAP without a reason; for simple UI micro-interactions prefer CSS per `ui-design` motion rules (no animation on 100+/day actions, UI under 300 ms, ease-out).

## Verify

Check in a real browser (the agent's browser tool, Playwright, or manually) at about 390 and 1440 px: scroll through ScrollTrigger sections, resize, navigate away and back (route change in the framework), and confirm no console errors, no duplicate triggers after remounts, no layout jump at pin start/end, and reduced-motion emulation behaves. For CWV and performance audits use the `web-quality` skill; for React/Next composition and bundle concerns use `vercel-next-react`.

## References (load on demand from `references/<file>`)

- Core: `core.md`, `core-2.md`, `core-3.md` (tweens, vars, transforms, stagger, easing, control, `gsap.matchMedia()`, best practices)
- `timeline.md`
- ScrollTrigger: `scrolltrigger.md`
- Plugins: `plugins.md`, `plugins-2.md`, `plugins-3.md`, `plugins-4.md`, `plugins-5.md`
- Utils: `utils.md`, `utils-2.md`, `utils-3.md`
- `react.md`
- Frameworks: `frameworks.md`, `frameworks-2.md`, `frameworks-3.md`
- `performance.md`
- `install-esm.md` (npm/ESM install, canonical `gsap.js` registry for every plugin and ease, prerequisites, types, UMD, SSR)
- `tips.md`, `tips-2.md` (best-usage tips and tricks, gotchas, debugging)

Sources: greensock/gsap-skills (MIT, Copyright (c) 2026 GreenSock). GSAP library: GSAP Standard License. Each reference file carries its source line.
