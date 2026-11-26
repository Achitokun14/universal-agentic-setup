---
name: astro-svelte
description: "Use for Astro or Svelte/SvelteKit code: query the Astro Docs and Svelte MCP docs before writing code"
---

Framework docs change fast (Svelte 5 runes, Astro 5 content layer). Query the docs MCPs before writing code; do not rely on memory.

## Pick the tier
- LOW (tiny edit, API certain): edit directly, then run the project's check (`pnpm exec astro check` / `pnpm exec svelte-check`).
- MEDIUM (new component/route/config): query the matching MCP first (below), then write.
- HIGH (migration, SSR/adapter, auth, perf): MCP docs + a library-docs MCP such as `context7` (if available) for library versions + the `vercel-deploy` skill (if installed) for hosting.

## MCP docs (add to your agent's MCP configuration if not present)
Servers `astro-docs` (https://mcp.docs.astro.build/mcp) and `svelte` (https://mcp.svelte.dev/mcp). If your agent has no MCP support, fall back to the official docs sites (docs.astro.build, svelte.dev/docs) fetched with the agent's web-fetch or search feature.
- Astro: use the docs search tool for the question (config option, integration, content collections, adapters, `astro:env`, view transitions). Cite the doc page you used.
- Svelte: use the section-listing tool, then the documentation-fetch tool for the relevant sections (svelte, kit, cli). Run the autofixer tool on every Svelte component you write or edit and apply its findings until clean. The playground-link tool only builds a share URL; skip it unless asked.
- Both are hosted, free, read-only doc lookups; they receive only your query text. Don't paste secrets or private code into queries.

## Astro conventions
- Static by default (`output: 'static'`); add an adapter (`@astrojs/vercel`) and per-route `export const prerender = false` only for on-demand routes.
- Zero JS by default: a framework component ships JS only with a client directive (`client:load`, `client:idle`, `client:visible`). Prefer `client:visible`/`idle`; keep logic in `.astro` frontmatter when possible.
- Content: typed collections in `src/content.config.ts` (loaders + zod schema), query with `getCollection`/`getEntry`; never hand-parse markdown.
- Env vars via `astro:env` schema (server secrets vs public); only `PUBLIC_*`-style/`public` values reach the client.
- Images: `astro:assets` `<Image>`/`<Picture>`, set width/height (CLS). Use `astro check` in CI.
- Scoped `<style>` by default; global CSS only through imports in layouts.

## Svelte 5 / SvelteKit conventions
- Runes, not stores/legacy: `$state`, `$derived` (not `$:`), `$effect` only for side effects (never to derive state), `$props()` instead of `export let`, snippets (`{#snippet}`/`{@render}`) instead of slots, `onclick={...}` instead of `on:click`.
- Do not mutate props; use `$bindable` only when needed. Always key `{#each}` blocks with stable ids.
- SvelteKit routing: `+page.svelte`, `+page.server.ts` (`load`, form `actions`), `+layout.*`, `+server.ts` (endpoints), `hooks.server.ts` (auth, handle). Secrets and DB access only in `.server` files / `$env/static/private`.
- Prefer progressive enhancement: `<form method="POST" use:enhance>` with actions over client fetch. Validate action input server-side.
- Adapter: `@sveltejs/adapter-vercel` for Vercel (`adapter-auto` also detects it); set runtime/regions in the route `config` export; prerender what can be static (`export const prerender = true`).
- Checks: `pnpm exec svelte-check --tsconfig ./tsconfig.json`, then the project's tests (Vitest, Playwright).

## Deploy notes (Vercel)
Both frameworks deploy with the authenticated `vercel` CLI (see the `vercel-deploy` skill if installed: token in the `VERCEL_TOKEN` environment variable from your secret manager, preview before prod, confirm with the user before any production deploy). Astro support in Vercel cost tuning is limited; SvelteKit is supported. Verify `build` output dir and adapter first with a local `pnpm build`.
