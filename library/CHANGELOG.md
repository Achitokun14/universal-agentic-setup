# Changelog

## Unreleased

- Antigravity install target documented and verified: `install.sh --agents antigravity` / `install.ps1 -Agents antigravity` copy skills to `~/.gemini/config/skills` (see README); `tools/agents/antigravity.json` lists the verified user and workspace skill folders.

## 0.1.0 - 2026-11-26

First export of the universal skill library.

- 70 portable skills: 29 from collection rounds 1-2, 6 from round 3, 35 consolidated from local skills (one project-specific skill was generalised into `awwwards-scrollstory`).
- Merges: docker (3 into 1), gsap-motion (2 into 1), plan-and-design (+ticket files, grill stub), engineering-workflow (+adversarial breaker matrix), web-ui-toolkit/ui-test-perfect de-duplicated. See `docs/MERGES.md`.
- Catalogue of third-party skills that are not bundled (`catalog/`).
- Tool manifests for winget/scoop, apt/dnf and Homebrew, plus npm/pipx lists; per-agent notes for omp, Claude Code, OpenCode, Codex CLI, Gemini CLI, Antigravity, Cursor, Hermes.
- Dry-run-first installers `install.sh` and `install.ps1`.
- Security tooling and results: `tools/security/`, `docs/SECURITY.md`.
