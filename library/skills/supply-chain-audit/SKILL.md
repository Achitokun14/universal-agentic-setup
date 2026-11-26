---
name: supply-chain-audit
description: "Use to audit project dependencies: CVEs, abandoned/archived upstreams, install scripts, lockfile tree risk."
---

Dependency supply-chain risk report for npm, PyPI and Go projects: version-matched advisories for direct dependencies plus an advisory sweep of the whole lockfile tree, abandoned/archived upstreams, npm publisher concentration, install-time script execution. Two deterministic stdlib-only scripts measure; the agent adds judgment. Read-only on the audited project: it never installs, builds or runs anything from it.

Attribution: scripts and method from trailofbits/skills `supply-chain-risk-auditor` (CC-BY-SA-4.0, https://github.com/trailofbits/skills). Scripts are shipped unmodified; this SKILL.md is an adaptation (condensed, cross-platform instructions) shared under CC-BY-SA-4.0.

## Pick the tier

- **LOW** (one lockfile, just "any known CVEs?"): `osv-scanner scan source -r .` in the project root `[verify with --help]`. No network metadata beyond the OSV database. Done.
- **MEDIUM** (default for "audit my dependencies"): run the collector + renderer below. Covers CVEs *and* abandonment, archived repos, install scripts, publisher concentration, OpenSSF Scorecard. Complement with `osv-scanner` for ecosystems/lockfiles the collector skips (see Rules).
- **HIGH** (pre-release / vendor review): MEDIUM + SBOM `syft scan dir:. -o cyclonedx-json=sbom.cdx.json` + `scorecard --repo=github.com/<owner>/<repo>` (needs a GitHub token in env `GITHUB_AUTH_TOKEN`, provided by your secret manager; never pasted on a command line) for the project's own repo + manual review of every flagged install script and top-risk upstream (use subagents if available to fan out per dependency; use web search for ownership/incident history).

## Run it

The scripts are single-file, standard-library-only Python (>=3.11), so they run with any `python3`/`python` of that version (or `uv run --no-project` if `uv` is installed). Below, `<skill-dir>` is the directory containing this SKILL.md.

Manifests required: `package.json`, `pyproject.toml`, `requirements*.txt`, or `go.mod`. If none exist, say so and stop. Lockfiles read for exact versions and the transitive sweep: `package-lock.json`/`npm-shrinkwrap.json`, `uv.lock`, go 1.17+ `go.mod`. `yarn.lock`, `pnpm-lock.yaml`, `poetry.lock` are **not** read (the report says so; versions fall back to pins or latest release) - run `osv-scanner` on those.

0. **Tell the user first, and wait for a go-ahead:** package names and versions from the dependency list are sent to public APIs (api.osv.dev, registry.npmjs.org, api.npmjs.org, pypi.org, proxy.golang.org, api.deps.dev, api.github.com, api.scorecard.dev). Nothing else leaves the machine; no source code is uploaded. Private/internal package names will be sent too - ask before running on a private project.
1. `gh auth status`. The collector reads the `gh auth token` output (never printed) to raise GitHub's limit from 60 to 5000 requests/hour. Without it expect repository criteria to come back "unassessable"; say so, do not silently fix it.
2. Collect, then render. Write outputs **outside** the audited repo:

#### macOS / Linux (bash)
```bash
out="${TMPDIR:-/tmp}/sca-out"; mkdir -p "$out"
s="<skill-dir>/scripts"
python3 "$s/collect.py" <project-dir> --json "$out/findings.json"
python3 "$s/render.py" "$out/findings.json" --out "$out/report.md"
```
#### Windows (PowerShell)
```powershell
$out = "$env:TEMP\sca-out"; New-Item -ItemType Directory -Force $out | Out-Null
$s = "<skill-dir>\scripts"
python "$s\collect.py" <project-dir> --json "$out\findings.json"
python "$s\render.py" "$out\findings.json" --out "$out\report.md"
```
   Needs Python >=3.11 (substitute `uv run --no-project` for `python3`/`python` if you use uv). Options: `--cache <dir>` (default: temp dir `supply-chain-risk-auditor-cache`), `--offline` (cached responses only). ~50 dependencies take a few minutes. If `collect.py` exits non-zero it is refusing to report (it measured nothing): relay its message verbatim; do not retry or work around it.
3. Read `report.md` (the deliverable) and `findings.json` (the datum behind every verdict).
4. Add a clearly separated addendum: what to act on first and why; upgrade path per advisory (patch vs major bump); replacement candidates for abandoned/archived deps (verify the candidate exists in the registry; label as judgment); for flagged install scripts whether `npm ci --ignore-scripts` is viable. Ask before changing anything.

## Script safety review (done at install)

`sources.py`: HTTP only via `urllib` GET/POST to the hosts above (one POST: OSV `querybatch` with package+version). Only subprocess calls are argv-list (no `shell=True`): `gh auth token`, and `pip-audit --no-deps --disable-pip` (only if pip-audit is on PATH; reads a requirements file, executes nothing from the target). No `eval`/`exec`/`pickle`; fetched data is parsed as JSON and treated as data. Writes only the `--json`/`--out` files and the HTTP cache under temp. `collect.py`/`render.py`/`model.py` are pure parsing/rendering.

## Rules

- **Measure with the scripts, never estimate.** Do not guess maintainer counts, download numbers, staleness or CVE history from `gh`, web search or memory; quote what the collector measured, verbatim, no re-derived or rounded figures.
- **Unassessable is not risk, and not clean either.** PyPI has no maintainer ACL, Go has no registry: those rows state what could not be known. Keep them in any summary; read the coverage table before repeating "no advisories" (means none among what was assessed).
- **Version label matters:** lockfile-resolved vs range-at-latest are different claims; keep the label.
- **Complement, do not replace, osv-scanner:** it covers more lockfile formats (pnpm, yarn, poetry, Cargo, etc.); this skill covers non-CVE signals. Name the ecosystems left unaudited; for unsupported ecosystems say unsupported, do not improvise.
- **Never auto-fix/upgrade/pin without explicit confirmation.** No `npm audit fix --force`, no lockfile edits, no `--fix`. Recommend; user decides. Pin only versions the team has reviewed, not "whatever is latest today".
- Deliverable carries facts; interpretive rules above stay out of it. Write report prose impersonal, declarative, finding + datum + action; no speculation about maintainers' motives.
- Out of scope: license compliance, scanning the target's own source for vulns/secrets (use the `security-review` skill if installed), build/install breakage, dependency source review.
- Report findings without printing secret values (tokens, auth headers).

## References

- `references/interpreting-results.md` - load when reading/summarizing the report: criteria, tiers, how to write the addendum.
