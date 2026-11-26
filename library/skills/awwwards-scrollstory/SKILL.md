---
name: awwwards-scrollstory
description: "Use for art-directed scroll-storytelling pages: scroll-driven motion, WebGL/canvas scenes, video heroes, OSS component sourcing, within performance, i18n and accessibility budgets."
---

> Method partly distilled from mengto/agent-skills build-awwwards-quality-sites (MIT, (c) 2026 Meng To). See SOURCES.md.

Turn a web surface (marketing site, landing page, inner page, shared UI package) into an art-directed, Awwwards-grade page that still meets the project's performance budgets, locale rules and honesty rules. Fill in the project's concrete numbers (budgets, locales, package names) from its own docs; the defaults below are sensible starting points.

Aesthetic direction, type choice and anti-template judgement come from a general frontend-design skill (if installed) or the project's design docs; this skill adds the acceptance bar and the reference library.

## Pick the tier

- **LOW** (one component or section: spacing, token, a reveal, a hover): apply the Rules; check the component in every shipped locale (including an RTL one if supported) and with reduced motion on; run the project's lint, typecheck and test commands for the owning package.
- **MEDIUM** (a new section, a component adopted from a library, an inner-page redesign):
  - Write the direction block below before any code.
  - Load the references that match the work.
  - Web changes end with a production build and the project's per-route JS-size gate (add one if missing; see Budgets).
- **HIGH** (home page, the hero, a cross-app system such as tokens, type or the motion layer):
  - Everything in MEDIUM, plus screenshots at 390 px and 1440 px in each locale, with motion on and with reduced motion, and one no-JS render.
  - Run a web-quality audit (Core Web Vitals and WCAG) with the `web-quality` skill if installed, or Lighthouse.
  - Hand the screenshots and gate output to an independent verifier (a fresh agent or the user); a claim without evidence counts as false.

Direction block (write it in the slice report before coding):

1. Surface and routes touched.
2. Visual thesis: one sentence.
3. The memorable moment: one per page, named, with its fallback.
4. Borrowed patterns, cited by name from `references/reference-sites.md`.
5. Section sequence, top to bottom.
6. Motion narrative and the systems used (CSS / GSAP / Motion / canvas).
7. WebGL decision: none, or which scene, which island, which poster.
8. Assets with provenance: licence or generator, disclosure.
9. Budget delta: first-load KB gz added and removed, deferred KB added.

## Rules

### Budgets
- Default web budgets (override with the project's own): first-load JS <=170 KB gz per route, LCP <=2500 ms, CLS <=0.05, INP <=200 ms. Never lower a budget to pass. A change that adds first-load JS removes at least as much elsewhere.
- New behaviour is CSS (with `animation-timeline: view()` inside `@supports`) or lives in a deferred island. GSAP, three, R3F and ogl are reached only through dynamic `import()`.
- The LCP element is the server-rendered hero poster or the H1. It is never animated, masked, split or delayed.
- Reveals use transform, opacity and clip-path only, inside reserved boxes.
- Apps without a route-size gate: keep per-page JS flat or lower, and never regress INP on dashboards.

### CSP (when the project enforces a strict Content-Security-Policy)
- Author no inline `<script>`, no `style` attribute, no `style` prop or `style:` directive carrying server-rendered values, and no injected `<style>`. Treat production CSP as forbidding inline code even if the framework's own internals need `'unsafe-inline'`; that is not permission for app code.
- Dynamic values go through classes, `data-*` attributes, or CSS custom properties set via CSSOM after mount (`el.style.setProperty`).
- Every font, image, video, model and texture is self-hosted (`img-src 'self' data: blob:`, `media-src 'self' blob:`, `connect-src 'self'` plus only the third parties the project already allows). No CDN, Google Fonts, Vimeo/YouTube iframe or remote HDRI. WASM decoders need `'wasm-unsafe-eval'`, which a strict CSP usually lacks.

### Locales and RTL
- Every surface ships every supported locale; if one is RTL (Arabic, Hebrew), treat RTL as first-class. All strings come from the catalogues; no text is baked into images, SVG paths or canvas.
- Logical properties and utilities only. Directional motion (marquee, slide, horizontal travel, route line) flips under `:dir(rtl)`.
- Arabic uses a `:lang(ar)` type recipe: zero tracking, no uppercase, no italics, taller leading, an Arabic display face. Never split Arabic text.
- Size layouts for languages that run 20-30% longer than English (French, German).

### Motion and reduced motion
- Server HTML is complete and visible without JS. JS only arms elements below the fold.
- Static triggers are `prefers-reduced-motion: reduce`, an explicit motion-off preference (cookie or setting), Save-Data, a low-capability tier and a frame-rate governor bail. Each one yields the complete final state: threads drawn, captions shown, video paused on its poster, canvas replaced by its poster, smooth scroll off. A shorter animation is not a static state.
- Loops longer than 5 s get a visible pause control and pause offscreen and on a hidden tab.
- No preloader, intro gate, "Enter" screen, sound prompt or auto-opening modal before content. No autoplay audio. No `user-scalable=no`.
- Pointer effects are additive, need `(hover: hover) and (pointer: fine)`, and always have a keyboard and touch path.

### One smooth-scroll engine
- At most Lenis, started once per document from one module, on marketing routes only. Never Locomotive, ScrollSmoother, fullPage, a virtual or transform scroller, or wheel-jacking snap.
- Wiring rules and the rAF-driver gotcha: `references/motion-choreography.md`.

### Hero = interactive video
- A self-hosted `<video muted playsinline loop>` with an AVIF poster as the LCP image, H1 and CTA as real DOM above it, and a scrim that keeps AA contrast over every frame.
- Interactive means the visitor changes what they see: pointer or scroll drives an aperture, parallax, scrub or reveal on the footage. The interaction is additive; the poster frame alone is a complete hero.
- The video starts after `load`, is never `preload`ed on the critical path, ships a smaller mobile rendition or a still, and stays at or below about 1.5 MB per rendition.
- Visible pause control. Reduced motion, Save-Data and the static tier show the poster only.
- Footage is licensed from the open web (licence recorded) or generated (with an image/video generation skill, if installed) and disclosed as AI-generated.

### One memorable moment per page
- Each page has exactly one named signature moment. Everything else is quiet: masthead type, chapter lighting, masked rises.
- No effect on every card. At most one WebGL context per route.

### Honest content and assets
- Borrow patterns only: never a reference site's copy, imagery, fonts, logos or code.
- Prices only from the real catalogue. No invented staff, testimonials, statistics, partners or outcomes. No third-party brand marks without permission.
- People appear only in real or licensed photos, never generated faces presented as real.
- Every asset carries its provenance. AI media is disclosed.
- Never call the result award-winning or Awwwards-recognised.

### Accessibility
- WCAG AA contrast for every token pair, including text over video and gradients.
- Visible focus, one H1 per page, real `<button>`/`<a>`, overlays with `inert` and focus return, `role="progressbar"`/`aria-current` on progress devices.

### Environment
- If the user already runs dev servers against live data, do not start, stop or restart them. Browse read-only and never submit forms.
- Keep every route, flow, form, server action and test contract.

## References

- `references/reference-sites.md`: load when choosing layouts or devices for a surface, or when filling item 4 of the direction block (borrow and refuse lists for the reference sites).
- `references/motion-choreography.md`: load when writing any intro, outro, route transition, reveal, scroll-telling chapter, pin, split text or smooth-scroll code.
- `references/webgl-canvas.md`: load when adding or changing a canvas, shader, R3F scene, grainy gradient, HTML-in-Canvas effect or poster.
- `references/component-sourcing.md`: load before copying any component from canvasui, kiboUI, magicUI, 21st.dev, aceternity, shadcn, LDRS, eldora, dotUI, smoothUI, unlumen or another OSS library, or before porting one to Svelte.
- Related skills, if installed, load when the work reaches them: `ui-design` (layout, type, colour, a11y), `gsap-motion` (GSAP API detail), `vercel-next-react` (Next / React), `astro-svelte` (Svelte 5), `web-quality` (audits), `higgsfield` and `media-generation` (hero footage).
