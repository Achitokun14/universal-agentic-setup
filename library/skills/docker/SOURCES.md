# Sources

Merged from the upstream `docker/skills` repository (Apache-2.0):

- `docker-build-strategies` (Apache-2.0): Dockerfile core guidance (multi-stage, layer caching, build secrets and SSH, `.dockerignore`, non-root, size, general rules), the multi-stage and layer-caching references, the Dockerfile/`.dockerignore` templates, the verification runbook and `verify-build` script.
- `docker-compose-patterns` (Apache-2.0): Compose core guidance (file naming, services, dependency modelling, health checks incl. the distroless sidecar, volumes, networks, env vars, dev overrides, Compose Watch, destructive commands), the service-dependencies and volumes-and-networks references, the web-app and dev-override templates, the bad-vs-good examples, the verification runbook and `verify-compose` script.

Where each lives in this skill:

| Upstream material | Here |
|---|---|
| docker-build-strategies SKILL.md core guidance | `references/build-strategies-1.md`, `references/build-strategies-2.md` (secrets and SSH) |
| references/multi-stage-builds.md | `references/multi-stage-builds-1.md`, `references/multi-stage-builds-2.md` |
| references/layer-caching.md | `references/layer-caching-1.md`, `references/layer-caching-2.md` |
| assets/Dockerfile.*, dockerignore-example | `references/templates-dockerfiles.md` |
| checks/verification.md (build) | `references/build-verification.md` |
| scripts/verify-build.sh | `scripts/verify-build.sh` + `scripts/verify-build.ps1` |
| docker-compose-patterns SKILL.md core guidance | `references/compose-patterns.md` |
| references/service-dependencies.md | `references/service-dependencies.md` |
| volumes and networks guidance | `references/volumes-and-networks.md` |
| assets/compose-web-app.yaml, compose-dev-override.yaml | `references/templates-compose.md` |
| assets/bad-vs-good.md | `references/bad-vs-good.md` |
| checks/verification.md (compose) | `references/compose-verification.md` |
| scripts/verify-compose.sh | `scripts/verify-compose.sh` + `scripts/verify-compose.ps1` |

Not carried over: upstream `skill.yaml` and `agents/openai.yaml` metadata (agent-specific), and references to sibling upstream skills (`docker-project-foundations`, `docker-destructive-guardrails`), which are not part of this skill.
