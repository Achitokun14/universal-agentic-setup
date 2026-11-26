---
name: monorepo-nx-turbo
description: "Use for Nx or Turborepo workspaces: generators, run/affected tasks, caching, package linking, imports."
---

Work in JS/TS monorepos: pnpm workspaces, Turborepo and Nx (workspace exploration, generators, task running and affected, plugins, package linking, `nx import`, caching). Examples use pnpm (`pnpm exec`/`pnpm dlx`, not bare `npx`); use the repo's own package manager (npm, yarn, bun) with the equivalent commands if it differs.

## Pick the tier

Detect the tool first: `nx.json` means Nx, `turbo.json` means Turborepo, only `pnpm-workspace.yaml` means plain workspaces. Respect what the repo already uses; recommend a tier change only when asked or when pain is evident.

- **LOW**: pnpm workspaces and package scripts (no orchestrator).
  - `pnpm -r build`, `pnpm --filter <pkg> dev`, `pnpm --filter "...[origin/main]" test`, `pnpm add @org/lib --filter @org/app --workspace`.
  - Load `pnpm-workspaces.md`.
- **MEDIUM**: Turborepo: task graph, cache, filters.
  - FIRST read `node_modules/turbo/docs/README.md` (version-matched docs; if not installed, install a pinned version, then read it).
  - `pnpm turbo run build test --concurrency=2`, `--affected`, `--filter=...`, `--dry=json`, `--summarize`.
  - Load `turborepo.md`.
- **HIGH**: Nx: generators, affected, project graph, module boundaries, `nx import`.
  - `pnpm nx show projects`, `pnpm nx show project <p> --json`, `pnpm nx affected -t build test lint`, `pnpm nx g <gen> --dry-run --no-interactive`, `pnpm nx graph`.
  - Load `nx-explore-run.md`, `nx-generate-link.md`, `nx-config-patterns.md`.
  - For large repos fan out per-project reviews or verification runs to subagents if the agent has them; use `jq` on `--json` output instead of reading output by eye.

## Rules

1. **Explore before acting.** Nx: `nx show project <p> --json` (full resolved config including plugin-inferred targets); `project.json` alone is incomplete. Turbo: read the bundled docs, then `turbo.json`. Plain: read `pnpm-workspace.yaml` and package scripts.
2. **Run through the tool's own graph.** Use the repo's tasks (`run-many`/`affected`, `turbo run`, `pnpm -r`) instead of invoking compilers directly, so dependencies build first and caching works.
3. **Cap parallelism** on small machines (few cores, limited free RAM): Nx `--parallel=2` (`NX_DAEMON=false` if memory is tight), Turbo `--concurrency=2` (default is 10), pnpm `--workspace-concurrency=2`. Do not run builds for the whole repo when `affected` suffices.
4. **Generators (Nx):** always `--no-interactive`; read the generator source, not only the schema; prefer a local workspace generator over a plugin one; match existing project patterns; `--dry-run` first; `--directory` is the full target path; libraries default to non-buildable; after generating, format and run build/lint/test/typecheck beyond the new project.
5. **Linking packages:** use the package manager's workspace command (`pnpm add @org/x --filter @org/app --workspace`), never tsconfig `paths` hacks or hand-edited versions. "Cannot find module @org/x" or TS2307 means a missing dependency declaration; add it and `pnpm install`.
6. **Caching correctness:** declare `outputs` and `inputs`/`namedInputs` explicitly; env vars that change output belong in the hash config (Turbo `env`, Nx `inputs`); never cache dev servers or deploy tasks; investigate misses with `--dry=json`/`--summarize` (Turbo) or `nx show project --json` inputs (Nx) before disabling the cache.
7. **Turborepo 2 uses `tasks`, not `pipeline`;** for 1.x configs run the official codemod (`pnpm dlx @turbo/codemod@<pinned-version> migrate`) after telling the user it executes remote code. Do not copy `pipeline` snippets from older docs.
8. **`nx import`** rewrites the destination repo and history: confirm source, destination directory and branch with the user, work on a branch, import one source subdirectory at a time, then fix pnpm workspace globs, root deps/`targetDefaults`/`namedInputs`, tsconfig, ESLint pin (v9), plugins. Details in `nx-import-1.md`, `nx-import-2.md`.
9. **Plugins:** `pnpm nx list`, `pnpm nx add @nx/<plugin>` (modifies package.json and nx.json: review the diff), then `pnpm nx reset` after config changes.
10. **Pin versions.** Scaffold with an explicit version checked via `npm view <pkg> version` (`create-turbo`, `create-nx-workspace`, `nx init`); never `@latest`, never `npx -y`.
11. **Excluded on purpose:** Nx Cloud (connect, CI self-healing, `nx-cloud` MCP flows), the optional Nx MCP server (it is `npx` remote code), and unauthenticated self-hosted cache servers. Keep `"neverConnectToCloud": true` in nx.json. Vercel Remote Cache (`turbo login`/`link`) and any publish (`changeset publish`, `npm publish`, `nx release`) are external actions: ask the user first and run only on explicit confirmation; pass tokens only through environment variables or your secret manager, never in files or command lines.
12. **Destructive cleanups need confirmation:** `git clean -fdX` and deleting lockfiles or `node_modules` of imported repos (`nx reset` only clears cache and is safe). Cross-platform scripts: no `rm -rf` in package scripts; use `rimraf` or a node one-liner.
13. **Verify before done:** run the project's own build/lint/test/typecheck for the affected scope (`nx affected`, `turbo run ... --affected`, `pnpm -r`). A passing generator or import is not done until these pass.

## References

- `references/pnpm-workspaces.md`: load for LOW tier work: pnpm workspace commands, structure, shared config packages, Changesets, cleanup on Windows.
- `references/turborepo.md`: load for any turbo.json, filter, cache debug or remote-cache question (MEDIUM).
- `references/nx-explore-run.md`: load to explore an Nx workspace, run tasks, use affected, or fix "cannot find configuration for task".
- `references/nx-generate-link.md`: load to run an Nx generator, add a plugin, or link workspace packages (any package manager).
- `references/nx-config-patterns.md`: load to set up or tune nx.json, tags and module boundaries, namedInputs, custom generators, CI.
- `references/nx-import-1.md`: load before `nx import`: strategy, directory conventions, critical post-import fixes.
- `references/nx-import-2.md`: load for ESLint/TypeScript/Jest fixes after import, non-Nx sources, and migrating a Turborepo repo into Nx.
