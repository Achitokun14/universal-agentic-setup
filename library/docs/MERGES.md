# Merges and dispositions

Nothing was dropped silently. This file records what happened to every skill considered for this library.

## Merges (content kept, one skill replaces several)

| Source skill(s) | Merged into | Where the content went | Notes |
|---|---|---|---|
| `docker-build-strategies`, `docker-compose-patterns` (docker/skills, Apache-2.0) | `docker` | `references/build-strategies-*.md`, `compose-patterns.md`, `multi-stage-builds-*.md`, `layer-caching-*.md`, `templates-*.md`, `volumes-and-networks.md`, `service-dependencies.md`, `bad-vs-good.md` + verification runbooks and verify scripts (`.sh` + `.ps1`) | attribution in `docker/SOURCES.md` |
| `gsap-scrolltrigger` (greensock/gsap-skills, MIT) | `gsap-motion` | `references/scrolltrigger.md` (full ScrollTrigger text; earlier partial copies removed because they were contained in it) | attribution in `gsap-motion/SOURCES.md` |
| `grill-me` (mattpocock/skills; a 1-line stub that calls another skill) | `plan-and-design` | existing "grill" section covers it; the stub itself is not copied | |
| `ticket-spec-writer` (round 2, staged duplicate) | `plan-and-design` | `references/ticket-files.md` (the rd/eval/board file split) | |
| `adversarial-breaker-review` (round 2, staged duplicate) | `engineering-workflow` | `references/adversarial-breaker-matrix.md`; round cap reconciled: default 2 rounds, up to 5 only when the user asks | `adversarial-review.md` updated to match |
| Duplicated UI-TARS block in `web-ui-toolkit` | `ui-test-perfect` (canonical home) | `web-ui-toolkit` now points to it and `requires` it in `skills/index.json` | both skills kept |
| `handoff` (round 3) | `unlazy-parallel` | `references/subtask-manifest.md` (parallel per-subtask manifest with write locks) | |
| a project-specific scroll-storytelling skill | renamed `awwwards-scrollstory` | project and brand specifics removed, generic scroll-storytelling rules kept | rename, not a drop |

## Not bundled (and why)

| Skill | Reason | Where recorded |
|---|---|---|
| `docx`, `pdf`, `xlsx` (anthropics/skills) | proprietary, all rights reserved: never redistributed | `catalog/third-party-skills.md`; `office-docs` re-describes the workflow with open tools |
| `build-with-exa`, `skill-scanner`, `systematic-debugging`, `remotion-best-practices`, `prompt-images`, `prompt-videos`, `hf-cli`, `security-and-hardening`, `obsidian-markdown`, `supabase-postgres-best-practices`, `convert-documents-to-markdown`, `frontend-design`, `mcp-builder`, `skill-creator` | third-party packs with their own licences and upstream owners: install from upstream | `catalog/third-party-skills.md` (source + install command) |
| `agent-workers`, `local-llm` | describe one maintainer's private machines and fleet; not portable | excluded from export; local copies untouched |
| ~337 other third-party skills found on the maintainer's machines (gstack-*, ruflo-*, marketing/CRO packs, railway-*, caveman, ponytail, ...) and 63 vendored skill collections | third-party packs, licences vary | `catalog/third-party-skills.md` group lists; 19 owner-specific entries are counted but not listed |
| Round 2 skipped duplicates and rejects | see `ROUNDS.md` | |
| Round 3 rejects: `hermes-prd-sync`, `shopify-agency-pipeline` | unsafe patterns (self-rewriting skills fed by an external channel plus unattended PR/production actions; auto-approve mode on a live store) | `ROUNDS.md` |

## Overlap kept on purpose

Some bundled skills overlap by design and cross-reference each other with "(if installed)": `ui-design`, `site-visual-direction`, `taste-art-direction-gate`, `hallmark-design-direction` (one art-direction skill per page, never two), `web-testing`, `dogfood-exploratory-qa`, `journey-completion-report`, `web-platform-behavior-checks`, `ui-test-perfect`, `security-review`, `supply-chain-audit`, `skill-authoring`, `skill-quality-gates`.
