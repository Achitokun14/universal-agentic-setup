---
name: react-three-fiber
description: "Use for React Three Fiber (R3F) 3D: Canvas, Drei, glTF, scroll, physics, XR, postprocessing, perf"
---

# React Three Fiber (R3F)

Build, fix and tune declarative three.js scenes in React: `Canvas`, hooks (`useFrame`, `useThree`, `useLoader`), the pmndrs ecosystem (Drei, postprocessing, Rapier, XR, uikit, gltfjsx), animation with GSAP/Motion, and a performance budget that suits weak GPUs. Facts were checked against the official docs and the published packages (fiber 9.8.2, drei 10.7.9, three 0.186) on 2026-10-26; each reference file carries its source line. No third-party agent skill was adopted; the guidance is written from primary docs.

## Library choice (check first)

- R3F for declarative 3D inside React; plain three.js (or the project's own `mountScene()`) for non-React/Svelte apps; GSAP or Motion only for DOM/UI motion around the canvas. In-scene motion: `useFrame`, `maath` damping, `@react-spring/three`, `motion/three`, or GSAP tweening objects.
- Pairing: R3F 9 needs React 19 (drei 10, postprocessing wrapper 3, rapier 2); R3F 8 needs React 18 (drei 9, rapier 1). v10/WebGPU only when the user opts in. Read `package.json` and match; run `npm view @react-three/fiber peerDependencies` before changing versions.
- Respect the existing stack: if the project already has WebGL guidance (for example lazy-loaded islands, a DPR cap, a poster fallback, CSP limits on WASM decoders), follow it and treat this skill as the R3F-specific layer.
- Avoid: `lamina` (archived), `framer-motion-3d` (npm-deprecated), `use-cannon`/`@react-three/cannon` (stale), `@react-three/flex` (React 18 peer, 2022), `@react-three/a11y` (stale), npm `@react-three/gltfjsx` (2022; the CLI is `npx gltfjsx`). Evidence and replacements: `references/setup.md`.

## Pick the tier

**Low: one Canvas with Drei helpers.** Load `references/setup.md` (install, Vite/Next, package map) and `references/tips.md` sections 1-4 (render loop, `demand`, dpr, sharing). Minimum shape:

```tsx
'use client' // Next App Router only
import { Canvas } from '@react-three/fiber'
import { OrbitControls, Environment } from '@react-three/drei'
export default function Scene() {
  return (
    <Canvas dpr={[1, 1.5]} gl={{ antialias: false, powerPreference: 'low-power' }} camera={{ position: [0, 0, 5], fov: 45 }}>
      <Environment files="/env/studio.hdr" />
      <mesh><boxGeometry /><meshStandardMaterial color="#ff6600" /></mesh>
      <OrbitControls makeDefault enablePan={false} />
    </Canvas>
  )
}
```

**Medium: glTF models, controls, lighting, scroll, postprocessing.**
- Models: `npx gltfjsx@6.5.3 public/m.glb -t -T` (downloads and runs the CLI: pin it and tell the user on first use), `useGLTF.preload`, one `<Suspense>`; compression and loading rules in `references/tips.md` sections 6-7.
- Events, Drei staples (`Bounds`, `Center`, `ContactShadows`, `ScrollControls`, `View`, `Html`, `Text`), lighting/shadows, colour and tone mapping, `EffectComposer` cost, fiber 9 typing changes: `references/tips-2.md`.
- Scroll and animation (GSAP `useGSAP` + ScrollTrigger, Motion `motion/three`, damping): `references/tips-3.md` section 1; page-level GSAP rules in the `gsap-motion` skill (if installed), Motion rules in the `motion` skill (if installed).

**High: instancing, physics, XR, shaders, performance budget.**
- Instancing and draw-call budget: `references/tips.md` section 4; iGPU/mobile budget table, debugging (renderer.info, r3f-perf, Spector), testing: `references/tips-3.md` sections 2-3, 6.
- Physics: `@react-three/rapier` `<Physics>` inside `<Suspense>`; prefer `cuboid`/`ball`/`hull` colliders over `trimesh` on moving bodies [INFERENCE: cheaper narrow-phase]; `<Physics updateLoop="independent">` with `frameloop="demand"`; `timeStep="vary"` is less stable; `debug` in dev only; `InstancedRigidBodies` for many bodies (Rapier readme).
- XR and 3D UI: `@react-three/xr` (`createXRStore`, `<XR>`, enter from a user gesture, HTTPS) and `@react-three/uikit`; read the official pmndrs SKILL.md files listed in `references/setup.md`.
- Shaders: `shaderMaterial` (Drei) or `extend()`; keep `uniforms` in `useMemo`, mutate `.value` in `useFrame`; end custom fragment shaders with the tone-mapping and colour-space chunks; `three-custom-shader-material` instead of `lamina`. WebGPU/TSL: opt-in per `references/setup.md`.

## Core rules (all tiers)

- Hooks (`useThree`, `useFrame`, `useLoader`, Drei hooks) run only in components rendered inside `<Canvas>`. The Canvas fills its parent, so the parent needs a definite size.
- **Never `setState` in `useFrame`, intervals or `onPointerMove`.** Mutate refs, scale by `delta`, hoist vectors/colours out of the loop, read fast external state with `store.getState()`.
- Idle scenes use `frameloop="demand"`; anything that mutates outside React (tweens, damping, scroll) calls `invalidate()`. Off-screen or hidden: `frameloop="never"`.
- Clamp resolution: `dpr={[1, 1.5]}` (use `1` on weak GPUs), `antialias: false` unless needed, `PerformanceMonitor` to step down. Fill-rate first, geometry second.
- Share geometry and material, instance repeats (`instancedMesh`, Drei `Instances`/`Merged`), keep lights constant, toggle `visible` rather than remounting heavy subtrees, never drive `args` from animation.
- Disposal: R3F disposes what it created; `dispose={null}` on shared/cached assets; `<primitive>` objects are yours to dispose; loader results are cached by URL, so clone rather than mutate.
- Assets: glTF only, Draco/meshopt geometry, KTX2 or WebP textures sized to need, `useGLTF.preload`/`useTexture.preload`, `<Suspense>` plus `<Preload all />`. Self-host decoders, HDRIs and fonts: Drei defaults and `Environment preset` use CDNs (CSP and production risk).
- Events: handlers only where needed, `stopPropagation` on occluders (they need a handler), `eventSource` on a shared parent for HTML overlays, a decorative canvas gets `pointer-events: none`.
- Colour: fiber 9 defaults to sRGB output and ACES tone mapping. Exact brand colours: `toneMapped={false}` or `flat`. With `EffectComposer` the renderer tone mapping is disabled, so add a `<ToneMapping />` effect last.
- Animation: one owner per property; no `framer-motion-3d`; with `frameloop="demand"` every external tween needs `invalidate()`; controls overwrite the camera, so tween their targets instead.
- Real copy and CTAs stay in the DOM; decorative canvas `aria-hidden`, meaningful canvas `role="img"` + label; honour `prefers-reduced-motion` (stop idle motion, render one frame).
- StrictMode mounts twice in dev: make effects idempotent with cleanup. With three >= 0.183 and fiber 9.8.2 expect a console deprecation warning from `THREE.Clock`; it is not a scene bug (read from sources, see `tips-2.md` section 6).
- Dev-only tools (`leva`, `r3f-perf`, `Stats`, `useHelper`, `Physics debug`) must not ship.
- Dependencies: check `npm view <pkg> deprecated time.modified peerDependencies` and the GitHub `archived` flag before adding any pmndrs package; keep one copy of `three`/`react`/`@react-three/fiber` (`npm ls`).

## Verify

In a real browser (automation tool if available, otherwise DevTools) at about 390 and 1440 px: the canvas renders a non-blank frame and the poster-to-canvas swap causes no layout shift; no console errors (the `Clock` warning is known); read `gl.info.render.calls`, `triangles`, `memory.geometries/textures` and compare with the budget (tips-3 section 2); fps on a real GPU browser (software WebGL in headless browsers makes fps meaningless: judge draw calls there); resize and orientation change; emulate `prefers-reduced-motion`; navigate away and back five times: one live WebGL context, `info.memory` returns to baseline, no leaked listeners/tweens; WebGL-off or `Canvas fallback` path shows the poster. For CWV and a11y audits use `web-quality`; for Next.js composition and bundle size use `vercel-next-react`; for GSAP rules `gsap-motion`.

## References (load on demand from `references/<file>`)

- `setup.md`: version pairing, install, Vite/Next/CDN/React Native, WebGPU opt-in, package map with maintenance status, packages to avoid, official pmndrs skills, hygiene.
- `tips.md`: render loop and state, `demand` rendering, dpr, draw calls and instancing, disposal, Suspense/preload/compression, gltfjsx workflow.
- `tips-2.md`: events and raycast cost, Drei staples, lighting and shadows, colour management and tone mapping, postprocessing, fiber 9 / React 19 changes.
- `tips-3.md`: GSAP and Motion integration, iGPU and mobile budget table, debugging and profiling, DOM integration, accessibility and lifecycle, testing.

Sources: pmndrs/react-three-fiber docs (MIT), pmndrs/drei docs (MIT), pmndrs/react-postprocessing, pmndrs/react-three-rapier, pmndrs/xr and pmndrs/uikit READMEs, pmndrs/gltfjsx README, threejs.org manual and r186 source, motion.dev/docs/three, GSAP docs, npm registry and GitHub API status checks (2026-10-26). Each reference file lists its own source line; budget numbers marked HEURISTIC are unsourced and must be measured.
