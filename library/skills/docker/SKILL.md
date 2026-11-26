---
name: docker
description: "Use for Dockerfiles, image size/build cache/hardening, and Docker Compose service wiring."
---

Write, review and debug Dockerfiles (build quality, cache, hardening) and `compose.yaml` (service wiring). Needs Docker 23+ (BuildKit default) and Docker Compose v2; on older Docker set `DOCKER_BUILDKIT=1`.

## Pick the tier

- **LOW** (small tweak, one-file question): review by eye against the Rules below. No tooling, no build.
- **MEDIUM** (new/edited Dockerfile or compose file): lint before declaring done (use the tools that are installed; otherwise review against the Rules).
  - `hadolint Dockerfile` (add `--ignore DL3008` only for a justified, noted reason)
  - `dclint compose.yaml` (`dclint .` lints a directory)
  - `docker compose config --quiet` validates the resolved Compose model without printing secrets (script: `scripts/verify-compose.sh` / `scripts/verify-compose.ps1`).
- **HIGH** (slow builds, big images, production hardening, runtime debugging): apply the full practice set.
  - BuildKit cache mounts for package managers, multi-stage builds, non-root final user, `HEALTHCHECK`/compose healthchecks, pinned tags, `.dockerignore`.
  - Measure: `docker build --progress=plain -t app:dev .` (second run should show `CACHED`), `docker images app`, `docker history app:dev`. Build verification script: `scripts/verify-build.sh` / `scripts/verify-build.ps1`; full runbooks in `references/build-verification.md` and `references/compose-verification.md`.
  - Inspect live stacks with a TUI such as `lazydocker` (if installed) instead of repeated `docker ps`/`logs` calls.
  - For multi-language or many-service stacks, fan out per-service reviews to subagents if the agent supports them.
  - Image CVE scanning (for example `trivy image`) only when the user asks for it.

## Machine constraints

Check the Docker host's memory and disk first (`docker info`, `docker system df`; Docker Desktop on Windows/macOS caps VM memory in its settings or `.wslconfig`).

- Keep container limits small on small hosts (`mem_limit: 256m`-`512m` per service, `deploy.resources.limits.memory` in Compose) and run only the services the task needs.
- Prefer a single database container, `postgres:*-alpine`/`redis:*-alpine` style images, and avoid JVM/Elasticsearch stacks unless required (set `-Xmx`/`ES_JAVA_OPTS` explicitly).
- Build with BuildKit. Avoid parallel multi-arch builds on small hosts; they exhaust RAM/disk.
- Windows: use PowerShell or forward-slash paths for bind mounts (`./src:/app/src`); Git Bash mangles `/c/...` and `/app` style paths (set `MSYS_NO_PATHCONV=1` if you must use it). Bind mounts from Windows drives are slow; keep `node_modules`/build output in a named volume or container-only path (see the volumes reference).

## Rules (Dockerfile)

1. First line `# syntax=docker/dockerfile:1`. Pin base images to a version or digest; never `latest` for production.
2. Multi-stage when there is a build step; name stages (`AS build`, `AS runtime`); copy only artifacts into the runtime stage; prefer distroless/alpine/`scratch` runtimes.
3. Order layers least- to most-changing: manifests + dependency install first, source after. Use `RUN --mount=type=cache` for npm/pip/go/apt caches and bind-mount lockfiles into install steps.
4. Always ship a `.dockerignore` (`.git`, `node_modules`, build output, `.env*`, IDE files, secrets).
5. Final stage runs as a **non-root** user (`USER app`, numeric UID where possible); no `sudo`, no SSH daemon.
6. Never put credentials in `ARG`/`ENV`/`COPY`; use `RUN --mount=type=secret` or `--mount=type=ssh` so they never land in a layer or `docker history`.
7. Combine related `RUN` steps; clean package-manager caches in the same layer (not needed with cache mounts); `--no-install-recommends` for apt.
8. Exec-form `CMD`/`ENTRYPOINT` (`["node","server.js"]`) so signals reach the process; add a `HEALTHCHECK` for long-running services.

## Rules (Compose)

1. File name `compose.yaml` (not `docker-compose.yml`); no top-level `version:`.
2. Lowercase role-based service names (`web`, `db`, `cache`, `worker`); pin image tags; one process per container.
3. Healthcheck every database/cache; order startup with `depends_on: {svc: {condition: service_healthy}}`, not sleep loops. Distroless images: use a healthcheck sidecar that shares the network namespace instead of baking tools in.
4. Named volumes for persistent data; bind mounts only for dev source. Default network is enough for one app; add custom networks only for isolation.
5. Secrets and credentials via `env_file`/Compose `secrets`, never inline literals in committed files. Take real values from your secret manager as environment variables for the one command (for example `POSTGRES_PASSWORD` exported only for `docker compose up`), never plaintext in the repo.
6. Dev-only settings in `compose.override.yaml`; prefer `develop.watch` over manual bind-mount syncing.
7. **Destructive commands need explicit user confirmation, naming the data that will be lost:** `docker compose down -v`/`--volumes`, `docker compose rm -v`, `docker volume rm|prune`, `docker system prune`, `docker rm -f` on data containers. For plain restarts use `docker compose restart` or `docker compose down` (no `-v`). Never run these as "cleanup" during debugging.
8. Publishing, pushing images (`docker push`) or deploying needs explicit user confirmation.

## Quick commands (identical in bash and PowerShell; chain with `;` in PowerShell, `&&` in bash)

```
hadolint Dockerfile
dclint compose.yaml
docker build --progress=plain -t app:dev .
docker run --rm -u 10001 app:dev id          # confirm non-root
docker compose config --quiet                # validate compose
docker compose up -d --build                 # ask the user first if it touches real data or ports
docker compose ps
docker compose logs -f web
docker stats --no-stream                     # check memory against the host's limit
```

## References

Dockerfile and build (from upstream docker-build-strategies):
- `references/build-strategies-1.md`: load when writing/reviewing a Dockerfile (multi-stage, caching, .dockerignore, non-root, size, general rules).
- `references/build-strategies-2.md`: load when a build needs credentials, tokens, private registries or SSH (BuildKit secrets).
- `references/multi-stage-builds-1.md`: load for Go and Node.js multi-stage patterns.
- `references/multi-stage-builds-2.md`: load for Python and Java multi-stage patterns and when to add stages.
- `references/layer-caching-1.md`: load for cache invalidation rules, BuildKit cache mounts, bind mounts.
- `references/layer-caching-2.md`: load for `COPY --link`, layer-count trade-offs, debugging cache misses.
- `references/templates-dockerfiles.md`: load to start from Go/Node/Python Dockerfile and `.dockerignore` templates.
- `references/build-verification.md`: load to verify a built image (size, non-root, no secrets, layers, WORKDIR/ENTRYPOINT).

Compose (from upstream docker-compose-patterns):
- `references/compose-patterns.md`: load for any Compose work (services, healthchecks, distroless sidecar, env, overrides, watch, destructive commands).
- `references/service-dependencies.md`: load for `depends_on` conditions, healthchecks per database, init containers.
- `references/volumes-and-networks.md`: load for volume types, node_modules exclusion, network isolation.
- `references/templates-compose.md`: load to start from a web+Postgres+Redis stack and a dev override.
- `references/bad-vs-good.md`: load to review a compose file against common mistakes.
- `references/compose-verification.md`: load to verify a compose file (schema, healthchecks, ordering, volumes, secrets, ports, tags).

Scripts (run from the project root): `scripts/verify-build.sh` and `scripts/verify-compose.sh` (bash), `scripts/verify-build.ps1` and `scripts/verify-compose.ps1` (PowerShell).

Provenance and licence: `SOURCES.md` (upstream docker/skills, Apache-2.0).
