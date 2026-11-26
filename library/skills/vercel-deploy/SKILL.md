---
name: vercel-deploy
description: "Use to deploy on Vercel or tune cost/perf via the authenticated CLI (Next, SvelteKit, Astro, Nuxt); every deploy, promote or settings change is ask-the-user-first."
---

Deploy to Vercel and tune cost/performance with the authenticated `vercel` CLI. Preview first, production only on explicit request. Every deploy or publish step, and every action that changes remote state, needs the user's explicit confirmation in this conversation: ask the user first.

## Hard rules

- **Authenticated CLI only.** Auth is the `VERCEL_TOKEN` environment variable, set for the command by your secret manager (or by the user's shell); the CLI reads it natively. Never use `--token`, never print, echo, log, or write the token to files, `.env`, shell history or chat. Never grep `.env` files for tokens; if no token is available, ask the user how they want to provide one.
  ```
  vercel whoami        # with VERCEL_TOKEN already present in the environment
  ```
- **Never use a tokenless/anonymous deploy path** (claimable-preview upload scripts or tarball endpoints). Uploading project sources to an unauthenticated third-party endpoint is forbidden; if the CLI cannot authenticate, stop and tell the user what is missing.
- **Ask the user first before:** `deploy` (even preview), `--prod`, `promote`, `rollback`, `link`, `env add/rm`, `domains add/rm`, `git push`, project/team setting changes, plan changes (billing). State exactly what will run (command, project, scope, environment) and wait for a yes. Read-only commands (`whoami`, `ls`, `inspect`, `logs`, `env ls`, `teams list`, `usage`, `metrics`) need no confirmation.
- **Preview before production.** Deploy preview (after the user agrees), check it (browser tool if available, plus the `web-quality`/`web-testing` skills if asked), then production only when the user explicitly says so; promote that exact verified deployment (`vercel promote <url>`) rather than rebuilding when possible.
- **Never push to git** (commit, push, tag, merge) unless the user asks; git-push deploys are the user's call.
- Do not read/modify `.vercel/` by hand (the CLI owns it; reading `orgId`/`projectId` to verify scope is fine). Do not run `vercel link`/`project inspect` in an unlinked directory to "detect state": they prompt or silently link. `vercel whoami` is safe anywhere.
- Secrets in project env vars: never put values on a command line. Pipe from the environment (see `references/cli-token-auth.md`). Prefer sensitive env vars for secrets; never commit `.env*`.
- Disabling Deployment Protection, adding domains, or spending (plan upgrades, usage-based features) is a user decision.
- Do not curl/spider the production site to "verify"; open the preview URL in a browser read-only when the user wants a smoke test (401 = protected deployment: tell the user, do not bypass).

## Pick the tier

- **LOW - read-only inspection and config review.** `vercel whoami | teams list | ls --format json --scope <team> | inspect <url> [--logs] | env ls --scope <team>`. Review `vercel.json`, framework adapter/config, `package.json` engines/build scripts (`references/framework-notes.md`).
- **MEDIUM - preview deploy and project wiring (ask the user first).** Gather state (git remote, `.vercel/project.json` or `repo.json`, `whoami`, `teams list`), ask for the team if several, then `vercel link --repo --scope <team>` (git remote) or `vercel link --scope <team>`, then `vercel deploy -y --no-wait --scope <team>` -> `vercel inspect <url>`. Details: `references/cli-token-auth.md`.
- **HIGH - cost/performance optimization and production releases.** Observability-first audit of usage and metrics, ranked recommendations, then (user-approved) production deploy/promote with rollback plan: `references/optimize-playbook.md` + `references/optimize-topics.md`. Use subagents (if available) for independent route investigations; keep each scoped to candidate files.

## Standard preview flow (only after the user said yes)

```
vercel whoami
vercel deploy -y --no-wait --scope <team-slug>
vercel inspect <deployment-url> --logs
```
`VERCEL_TOKEN` must already be in the environment of these commands; it never appears in the command line. `-y` skips prompts (only after the user approved the target); `--no-wait` returns at once, so poll with `inspect`. Show the user the deployment URL. If the CLI is missing, ask the user before installing it (`pnpm add -g vercel@<pinned-version>` installs code globally; `npx vercel@<pinned-version>` is a one-off alternative). Check `vercel --version` and use a version that has the commands you need.

## Frameworks (details in `references/framework-notes.md`)

- **Next.js:** auto-detected; do not set `output: 'standalone'` for Vercel; caching/ISR/Cache Components semantics depend on the Next version (`vercel-next-react` skill, if installed).
- **SvelteKit:** `@sveltejs/adapter-vercel` (pin it; options differ by adapter version).
- **Astro:** static needs no adapter; SSR/on-demand needs `@astrojs/vercel`. Use the `astro-svelte` skill or the Astro/Svelte docs (docs MCP servers if connected) for framework config questions; use the vendor docs (or a docs MCP server such as Context7, if connected) for Nuxt and Vercel.
- **Nuxt:** Nitro `vercel` preset is auto-detected; per-route caching via `routeRules`.

## Common failures

Missing env vars at build, wrong root directory in monorepos, Node version mismatch (`engines.node` / project setting), lockfile not committed, build output not matching the framework preset: read `vercel inspect <url> --logs`, fix in source/config, redeploy preview (after asking the user). Do not "fix" by weakening type checks or lint gates without telling the user.

## References

- `references/cli-token-auth.md` - load for token handling, scope/link flow, env var management, domains, logs, rollback and promote.
- `references/framework-notes.md` - load for Next/SvelteKit/Astro/Nuxt build, adapter, runtime, ISR and monorepo settings.
- `references/optimize-playbook.md` - load for cost and performance tuning: doctrine, metric collection with `vercel usage/metrics`, gating, report shape.
- `references/optimize-topics.md` - load while investigating candidates: per-topic rules (caching, ISR, images, middleware, bots, build minutes, ...) and application-profile tilts.
