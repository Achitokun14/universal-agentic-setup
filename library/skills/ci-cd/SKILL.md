---
name: ci-cd
description: "Use when writing or reviewing GitHub Actions or GitLab CI pipelines, deployment gates, or CI secrets handling."
---

# CI/CD pipelines (GitHub Actions, GitLab CI, deploy gates, CI secrets)

Write, review and debug pipelines that are least-privilege, pinned, cached and gated. This skill writes files and reads CI state; it never deploys or pushes by itself.

## Pick the tier

- **LOW** - minimal workflow, no extra tooling. One trigger, one job, `permissions: contents: read`, every third-party action pinned to a full commit SHA, `actions/checkout` with `persist-credentials: false`, a `timeout-minutes`, `concurrency` with `cancel-in-progress` for PR runs. Template: `references/github-actions.md` (minimal test workflow).
- **MEDIUM** - LOW plus a static audit and speed. After writing/changing any workflow run `zizmor .github/workflows` (if installed; otherwise review against the Rules below) and fix every finding or justify it in a comment; add dependency cache (`setup-node`/`setup-python` `cache:` input, or `actions/cache` keyed on the lockfile hash), matrix builds with `fail-fast: false`, path filters, artifacts with `retention-days`, reusable workflows (`workflow_call`) for repeated blocks. Docker image build: `docker/build-push-action` with GHA cache; lint the Dockerfile with `hadolint`.
- **HIGH** - release/deploy pipelines: GitHub `environment:` with required reviewers, OIDC federation to the cloud (`id-token: write` on the deploy job only, no long-lived keys), build-once-promote-the-artifact, canary/blue-green/rolling with automated rollback, DB-migration ordering, health-check gates; also all GitLab CI work (protected/masked variables, `environment:`, `rules:`, `needs:`, child pipelines). Read `references/deploy-gates.md` and `references/gitlab-ci.md`.

For fork PRs, `pull_request_target`, `workflow_run`, self-hosted runners, caches shared across trust levels, or any workflow that runs an AI agent/untrusted input: apply the CI-agent-vector rules of the `security-review` skill (if installed). Summary here: never check out and run PR-head code under `pull_request_target`; never interpolate `${{ github.event.* }}` into `run:`; agents get a read-only token and no secrets.

## Workflow

1. Detect the stack: lockfiles (`package-lock.json`, `pnpm-lock.yaml`, `uv.lock`, `go.mod`, `Cargo.lock`), existing `.github/workflows/`, `.gitlab-ci.yml`, Dockerfile. Reuse existing jobs and naming; do not create a second convention.
2. Write the smallest pipeline that gives the check the user asked for: lint -> test -> build; deploy is a separate workflow/job.
3. Resolve every action to a SHA before writing it (read-only):
   `gh api repos/actions/checkout/commits/v4 --jq .sha` (works for tags and branches; repeat per action; write `uses: actions/checkout@<40-hex-sha> # v4`). Never write `@main`, `@master`, `@latest`, or a bare tag for third-party actions.
4. MEDIUM+: run `zizmor .github/workflows`; for local secret scanning of the repo before pushing use a scanner such as `gitleaks` or `betterleaks` (if installed); for dependency findings `osv-scanner`.
5. Read run state with `gh run list`, `gh run view <id> --log-failed`, `gh run watch <id>` (read-only). `gh workflow run`, re-runs, tag pushes, release creation and any `git push` are side effects: **ask the user first**, naming repo, ref and workflow.
6. Report: files written, what each job does, permissions granted and why, zizmor result, and what still needs the user (secrets to create, environments to configure, branch protection).

## Rules

- Default `permissions: {}` or `contents: read` at workflow level; widen per job and only for the scope needed (`packages: write`, `id-token: write`, `pull-requests: write`).
- Pin third-party actions to a commit SHA with a trailing `# vX.Y.Z` comment; first-party `actions/*` may use a version tag only at LOW if the user insists, SHA preferred. Pin container images by tag + digest where practical (`node:20-bookworm`, not `latest`).
- Untrusted input (`github.event.pull_request.title`, branch names, issue bodies, `head_ref`) goes through an `env:` variable and is quoted in the shell, never interpolated into `run:` or `github-script`.
- Secrets: never `echo`, `set -x`, `cat` or print them; do not pass via CLI args or write to artifacts/caches; use the CI secret store (GitHub Secrets/Environments, GitLab masked+protected variables) or OIDC. Scope secrets to the environment that needs them; different values per environment. For local/dev use, take values from your secret manager into environment variables with the names the tool expects (for example `GH_TOKEN`) for that one command only; never ask for or paste plaintext. Creating/rotating a remote secret is a user-confirmed action.
- A deploy job needs: an `environment:` (with protection rules), `concurrency` (no parallel deploys to the same env), a health check after deploy, and a documented rollback (previous image/artifact tag retained). Production deploys are manual-approval or tag-triggered; staging may auto-deploy from the default branch.
- Build once, promote the same immutable artifact (image digest) through environments. Never rebuild per environment.
- DB migrations: additive/backward-compatible for one release; no destructive change until the old version is retired everywhere.
- Cache keys include the lockfile hash; never cache secrets or credentials dirs; do not restore caches written by untrusted (fork) runs into privileged jobs.
- Keep CI fast: path filters, matrix only where it pays, `fail-fast: false` for matrices that diagnose, timeouts everywhere, no `sleep` polling when a `needs:` dependency works.
- Self-hosted runners only for private repos; ephemeral, no persistent credentials.
- NEVER run or add anything that deploys, pushes images, publishes packages, or posts notifications on your own; write the workflow and let the user trigger it. Strip auto-deploy-on-push-to-main for production unless the user explicitly asks for it.
- Notifications (Slack/Teams webhooks) only when asked; webhook URL lives in a secret.

## Debugging failed pipelines

1. `gh run view <id> --log-failed` (or GitLab job log); find the first failing step, not the last.
2. Classify: config error (YAML/expression), environment (missing secret/permission/cache), flaky test, real failure. Reproduce locally where possible (same command from the workflow, same Node/Python version).
3. "Resource not accessible by integration" = missing `permissions:`; empty secret on fork PR = expected; approval gate waiting forever = environment reviewers not configured.
4. Fix, re-run only after the user agrees to push/trigger.

## References

- `references/github-actions.md` - load when writing/reviewing GitHub Actions: minimal, test, matrix, Docker, reusable, security-scan templates.
- `references/gitlab-ci.md` - load for any `.gitlab-ci.yml` work: stages, rules, cache, environments, protected variables, child pipelines.
- `references/deploy-gates.md` - load when designing deploy pipelines: environments, OIDC, strategies, health checks, rollback, readiness checklist.
- `references/secrets.md` - load when wiring CI secrets, rotation, external stores, secret scanning.
- Security cross-link: the `security-review` skill (if installed) for `pull_request_target` and agent-in-CI sandbox rules.
