---
name: vercel-next-react
description: "Use for React/Next.js code: perf rules, composition patterns, App Router, caching, bundle size, dev-loop."
---

Write, review and speed up React and Next.js (App Router) code. This file is a router: pick the tier, apply the short rules, load only the reference you need.

## Docs first: version-matched beats memory

1. **Installed Next.js docs (preferred, offline):** if `node_modules/next/dist/docs/` exists (bundled since Next 16.2), read the matching guide there before editing: search that folder for `<slug>.md` (layout is numbered, e.g. `01-app/02-guides/`). The installed version is authoritative for flags and API signatures. Check the version with `pnpm exec next --version` (or `npx next --version`).
2. **A docs MCP server (e.g. Context7) if connected, or web search**, for library docs when the bundled docs are absent.
3. **Fallback: the references below** (written for Next 15/16 App Router + React 19; verify against the installed version).

Do **not** auto-run `npx @next/codemod@latest agents-md` (or any `@latest` codemod): it fetches remote code and writes into the repo. If the project would benefit (older Next without bundled docs), tell the user what it does and offer a pinned, explicit-approval run (`npx @next/codemod@<pinned-version> <codemod>` on a clean git tree, review the diff). The same applies to `next upgrade`: propose, get approval, review the diff.

## Pick the tier

- **LOW - quick review/fix of a component or route.** Apply the Rules below directly; no tools beyond reading, searching and the language server (if available). Use the agent's AST/code-search tooling or plain search-and-replace for mechanical codemods inside the repo.
- **MEDIUM - build and verify a change.** `pnpm exec tsc --noEmit`, `pnpm lint`, `pnpm build` (the production build shows route types: static / PPR / dynamic). Verify in a running app with a browser tool (page snapshot, console errors, network requests, React DevTools or profiler for render and boundary checks). With Next 16.3+ on Turbopack, also use the dev server's `/_next/mcp` endpoint (see `references/next-dev-loop.md`).
- **HIGH - measured optimization.** Bundle analysis (`next analyze` / `next experimental-analyze` depending on the version) -> `references/next-bundle-optimizer.md`; waterfalls/CWV -> `references/react-rules-critical.md` plus the `web-quality` skill (if installed; Lighthouse/trace); Cache Components or Partial Prefetching adoption (Next 16.3+ only, long workflows) -> the two next16 references, load **only on request**. Use subagents (if available) to audit independent routes in parallel; one agent owns the shared stores/layouts.

## Rules (highest-value, always on)

1. **Server Components by default.** Add `'use client'` only for hooks, event handlers, browser APIs. Push it to leaf components; never make a client component `async`.
2. **Eliminate waterfalls first** (CRITICAL): start independent promises together (`Promise.all`), move `await` into the branch that needs it, check cheap sync conditions before async flags, stream slow parts with `<Suspense>`, wrap per-request fetches in `React.cache()`.
3. **Cut client JS** (CRITICAL): import from the module, not barrel files; `next/dynamic` for heavy/rare UI; load analytics after hydration; statically analyzable import and fs paths.
4. **Server Actions are public endpoints:** authenticate and authorize inside each action, validate input (zod), then mutate. Do not rely on middleware/proxy or layout guards alone.
5. **Serialization boundary:** props to client components must be serializable (no functions except Server Actions, no `Date`/`Map`/`Set`/class instances); pass only the fields the client uses; don't pass the same array twice in different shapes.
6. **No module-level mutable request state** in RSC/SSR (concurrent renders share the process).
7. **Async request APIs (Next 15+):** `await params`, `await searchParams`, `await cookies()`, `await headers()`; type `params` as `Promise<...>`; `use(params)` in sync components.
8. **Don't wrap `redirect()/notFound()/forbidden()/unauthorized()` in try/catch** (or call `unstable_rethrow(e)` first).
9. **Data pattern:** reads in Server Components, mutations via Server Actions, Route Handlers only for external/public APIs and webhooks; `route.ts` and `page.tsx` cannot share a folder.
10. **Use `next/image`, `next/font`, `next/script`, the Metadata API**; `priority`/`preload` only for the LCP image; always `sizes` with `fill`; remote hosts in `images.remotePatterns`; never fetch fonts from link tags.
11. **`useSearchParams`/dynamic `usePathname` need a `<Suspense>`** or the page falls back to client rendering.
12. **Hydration mismatches:** no `window`, `Date.now()`, `Math.random()`, locale-dependent formatting or invalid HTML nesting in the first render; use `useId`, effects, or `suppressHydrationWarning` only for genuinely expected diffs.
13. **Re-render hygiene (measure first):** derive state during render, functional `setState`, primitive effect deps, `startTransition`/`useDeferredValue` for non-urgent work, no components defined inside components, `&&` with numbers -> use ternaries, memoize only proven hot paths (React Compiler handles most).
14. **Composition over boolean props:** compound components + a provider that owns state; explicit variant components; children instead of `renderX` props (`references/composition-patterns.md`).
15. **Next 16 specifics:** `middleware.ts` is `proxy.ts` (export `proxy`, config `proxyConfig`); Turbopack is the default bundler; do not flag `proxy.ts` as a misnamed file.
16. Prefer Node runtime; `runtime = 'edge'` only when already used or required.
17. Never ship secrets in `NEXT_PUBLIC_*`; those are inlined at build time.
18. **Deploying** (Vercel CLI, env, preview/prod) is the `vercel-deploy` skill (if installed); self-hosting notes are in `references/next-build-hosting.md`. Ask the user first; never deploy or push without explicit confirmation.

## References

- `references/react-rules-critical.md` - load for waterfalls, bundle size and server-side rules with code (priority 1-3).
- `references/react-rules-more.md` - load for client fetching, re-render, rendering, JS micro-perf and advanced rules (priority 4-8).
- `references/composition-patterns.md` - load when refactoring boolean-prop components, compound components, context interfaces, React 19 API changes.
- `references/view-transitions.md` - load when adding page/route/shared-element/list animations with `<ViewTransition>`.
- `references/next-rsc-data.md` - load for RSC boundary errors, async params/cookies, data-fetching patterns, directives, Suspense bailout, hydration errors.
- `references/next-routing-errors.md` - load for file conventions, route handlers, parallel/intercepting routes, error handling, proxy, runtime choice.
- `references/next-assets-metadata.md` - load for metadata/OG images/sitemap, next/image, next/font, next/script.
- `references/next-build-hosting.md` - load for bundling errors, Turbopack, bundle analysis commands, `output: 'standalone'`, ISR cache handlers, self-hosting.
- `references/app-router-ecosystem.md` - load for App Router layout/provider patterns, state management choice, Tailwind v4 tokens, React 18/19 modernization.
- `references/next-dev-loop.md` - load to verify runtime behavior after edits with `/_next/mcp` and a browser tool (Next 16.3+, Turbopack).
- `references/next-bundle-optimizer.md` - load for an evidence-based client-bundle audit/fix with `next analyze`.
- `references/next16-cache-components.md` - **on request only**: enabling Cache Components (`cacheComponents`) and clearing blocking routes (Next 16.3+).
- `references/next16-partial-prefetching.md` - **on request only**: Partial Prefetching adoption/optimization (Next 16.3+, requires Cache Components).
