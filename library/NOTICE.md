# NOTICE - provenance and licences of the bundled skills

Each skill folder that derives from upstream material carries a `SOURCES.md` (upstream project, licence, what was taken). Most text was distilled/rewritten; a few files keep verbatim upstream text with their original header. This file aggregates them.

## Licence caveats (read before choosing a repository licence)

- **CC BY-SA 4.0 (share-alike)** material is present in: engineering-workflow, security-review, supply-chain-audit. Derivatives of that material must stay under CC BY-SA 4.0.
- **CC BY-NC 4.0 (non-commercial)** is the licence of the upstream project that inspired `research/references/academic.md` (restated in own words, no text copied). Treat that file as non-commercial or remove it.
- Several references were distilled from upstream projects whose licence is not stated in the local copy (listed in the relevant `SOURCES.md`). Verify before relaxing the licence.
- Nothing from proprietary (all-rights-reserved) skills is bundled: docx, pdf and xlsx from Anthropic are catalogued only (see `catalog/`).

## ai-research-ml


- Orchestra-Research/AI-research-SKILLs - MIT, (c) Claude AI Research Skills Contributors. The topic index and the `gguf`, `llama-cpp`, `peft`, `trl-fine-tuning`, `unsloth`, `lm-evaluation-harness`, `mlflow`, `ml-paper-writing`, `academic-plotting`, `0-autoresearch-skill` and `brainstorming-research-ideas` distillations come from it. The library itself is not bundled; `LIB` points to the user's own clone.
- wshobson/agents - MIT. `eval-harness-first` and `finetuning-method-selection` distillations.
- The paper-writing philosophy credited in `references/paper-writing.md` is by Nanda, Farquhar, Perez, Lipton, Steinhardt, Gopen and Swan (as cited in the upstream skill).

Cron/heartbeat "continuity" machinery present upstream was intentionally dropped.

## animation-audit-suite


- Upstream: https://github.com/emilkowalski/skills (MIT, Copyright 2026 Emil Kowalski).
- Taken: the ideas and values of three upstream skills (improve-animations, find-animation-opportunities, remove-animations), condensed into one three-mode audit skill (`find`, `remove`, `improve`) and two reference files (`references/audit-categories.md`, `references/plan-template.md`).
- Local changes: `remove` mode asks the user before the first edit; `improve` plan execution only on explicit request.
- Written in the distiller's own words; no upstream files are copied verbatim.

## animation-choreography


- Upstream: https://github.com/emilkowalski/skills (MIT, Copyright 2026 Emil Kowalski).
- Taken: the choreograph skill (relationships between simultaneous animations), condensed into `SKILL.md` and `references/recipes.md`.
- Written in the distiller's own words; values are starting points.

## autoresearch-loop


Method distilled from these MIT-licensed projects (the upstream scripts, hooks and installers were intentionally not used):

- uditgoenka/autoresearch
- affaan-m/ecc (`autonomous-loops`, `eval-harness`, `benchmark-optimization-loop`)
- EveryInc/compound-engineering-plugin (`ce-optimize`)

## awwwards-scrollstory


- mengto/agent-skills `build-awwwards-quality-sites` - MIT, (c) 2026 Meng To. The direction-block method and parts of the motion and WebGL guidance are distilled from it.
- Per-site pattern notes (reference-sites.md) are original observations of public websites: transferable devices only, never copy, imagery, fonts, logos or code.
- Component libraries named in `references/component-sourcing.md` are listed as places to look; each has its own licence, which must be checked per component.

## batch-worktree-migration


- Origin: compendium `Agentic_Skills_Wayfinder_Unlazy_HeadStart_AstryxMax_UIUXProMax_and_BorisCherny.md`, heading "5.5 `boris-cherny-core-suite`", item "1. `/batch <instruction>`", from video #62 "The Claude Code Skill Boris Cherny Runs on Every Project" (channel AI LABS); the strategy PDF `Strategy_Boris_Cherny_Claude_Setup_Fable51_Advisor_Fleet_Engineering_and_Claude_OS.pdf` and the tool catalog `Tools_Catalog_GrokBot_Buzz_Meta_Astryx_Hermes_MCP_DeepSec_and_ScaleKit.pdf` mention the same command. The compendium says it "reconstructs" the workflow and states no license or upstream text.
- Taken: plan with an end-to-end verification command, N parallel units each in its own git worktree, merge into one consolidated pull request.
- Changed: user approval for the plan and again before any push or pull request; merge into a local integration branch first; unit cap; no forced operations; cleanup only of what the run created.

## ci-cd


Distilled from MIT-licensed projects, rewritten with SHA pinning, least privilege and user-confirmed deploys:

- wshobson/agents: `github-actions-templates`, `gitlab-ci-patterns`, `deployment-pipeline-design`, `secrets-management`
- affaan-m/ecc: `deployment-patterns`

## cook-visual-match


- Upstream: https://github.com/Leonxlnx/cook (MIT, Leon Lin).
- Taken: the round-based visual-match loop (intake brief, shot list, numeric bar, fresh-context critics, round ledger, ship rules), written in the distiller's own words.
- Local changes: pushing, publishing, posting, downloading and long or costly exports require the user's confirmation in the current conversation (a Permissions line in a brief is a reminder only); default cap of 3 rounds or 2 hours when no cap is given; the upstream side-by-side script is replaced by a manual HTML comparison page; references to other skills are conditional ("if installed").

## design-corrections-to-rules


- Upstream: https://github.com/emilkowalski/skills (MIT, Copyright 2026 Emil Kowalski); the learn-taste skill.
- Taken: the idea of turning a user's design corrections into rules with reasons, condensed in the distiller's own words.
- Local changes: writes nothing until the user approves; reads only the current conversation; never edits agent configuration files (gives the text to paste instead); creating a project skill needs the user's approval.

## design-target-first-loop


- Upstream: https://github.com/Leonxlnx/cook (MIT, Leon Lin), plus the Hallmark and Stageshow stacking advice (see `hallmark-design-direction` and `stageshow` SOURCES.md).
- Taken: the workflow ordering (references, three-direction target sheet, static layout before motion, cold judging, reverse-describe feedback, one art director per page), distilled from notes on that workflow and written in the distiller's own words.

## diagrams-architecture


- Archify (`tt-a1i/archify`, v3.1), MIT, Copyright (c) 2026 tt-a1i, (c) 2025 Cocoon AI. Taken: renderers, schemas, locales, bin scripts, recipes, 11 example JSON files (`scripts/archify/`), the HTML template (without its embedded font), and condensed/original skill text split into `references/archify-skill-1..4.md`, `authoring-*.md`, `delivery-*.md`, `repository-authoring.md`, `layout-repair.md`, `schemas.md`. License: `scripts/archify/LICENSE`. Third-party brand-mark notices: `scripts/archify/THIRD_PARTY_NOTICES.md`.
- Removed from the redistribution: the update-check scripts, upstream example HTML, website, tests, and the embedded JetBrains Mono (OFL) font data and its license file.
- `references/mermaid.md`: own summary of Mermaid syntax and `@mermaid-js/mermaid-cli` usage (no upstream text copied).

## docker


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

## docs-claim-verification


- Upstream: vercel-labs/deepsec (https://github.com/vercel-labs/deepsec), `.agents/skills/technical-writer`, Apache-2.0 (repo license).
- Taken: the claim-to-evidence matrix (`references/evidence-matrix.md`) and the doc page patterns (`references/page-patterns.md`), distilled; the verification rules in `SKILL.md` follow the same method.
- Added locally: destructive, billable or networked commands need the user's approval before they run.

## dogfood-exploratory-qa


- Upstream: vercel-labs/agent-browser (https://github.com/vercel-labs/agent-browser), Apache-2.0.
- Taken: the method of the `dogfood` skill-data (report template restated in original wording, issue taxonomy, exploration checklist) and `skill-data/core/references/trust-boundaries.md` (distilled into `references/untrusted-page-content.md`).
- Not taken: the agent-browser CLI (not used) and the cookie-file import advice (intentionally dropped).
- Added locally: never attach to the user's real logged-in browser profile; production stays read-only.

## egm-dual-pass-review


- Upstream: google/elephant-goldfish-model (https://github.com/google/elephant-goldfish-model), Apache-2.0.
- Taken: the builder ("elephant") / fresh-context reviewer ("goldfish") protocol, the reviewer lens set (`references/lenses.md`), and the aggregated report and triage format (`references/report-format.md`), distilled and restated.
- Added locally: never send `.env` or other secret files to the reviewer; redact credentials.

## email-react-resend


Distilled from resend/resend-skills (MIT): `resend`, `resend-cli`, `agent-email-inbox`, `react-email` (incl. its SENDING notes), email best practices and email accessibility. The local-test-inbox notes for Mailpit are original.

## engineering-workflow


This skill is a distillation; each reference file also carries its own attribution header. Upstream projects named in those headers:

- MIT: mattpocock/skills, obra/superpowers, EveryInc compound-engineering-plugin, wshobson/agents, garrytan/gstack, mrclrchtr/supi, affaan-m/ecc.
- CC BY-SA 4.0: trailofbits/skills (`property-based-testing`, `modern-python`). `references/property-tests.md` and `references/python-uv.md` are rewritten from it, keep their attribution, and are likewise shareable under CC BY-SA 4.0.
- `references/adversarial-breaker-matrix.md`: the attack categories were summarized from public video material (no upstream licence) and restated in original words; the procedure was merged from a local `adversarial-breaker-review` skill.

Telemetry, update preambles, remote codemod fetching and floating-tag installs present in some upstream sources were intentionally dropped.

## expo-animation


- Upstream: https://github.com/emilkowalski/skills (MIT, Copyright 2026 Emil Kowalski); the animate-expo skill.
- Taken: the React Native / Expo animation decision sequence, spring and curve tables, gesture and UI recipes (`references/`).
- Local changes: dependency installs require asking the user first; one spring value that contradicted the skill's own table was fixed.

## gesture-driven-ui


- Upstream: https://github.com/emilkowalski/skills (MIT, Copyright 2026 Emil Kowalski); the gestures skill, including its Apple WWDC-derived fluid-interface formulas.
- Taken: track/release gesture model, interruptibility, momentum projection, Vaul-style sheet curves, hold-to-confirm; values are starting points.
- Local change: contradictory spring guidance (bounce versus damping ratio) was resolved.

## google-workspace


- googleworkspace/cli (Apache-2.0): the command syntax, helper commands and recipes in the "Upstream gws" sections and `references/workflow-recipes.md` are distilled from its `gws-*` skills.
- workspace-mcp (PyPI package `workspace-mcp`): tool names and server flags for "mode A" were read from its `--help` output and package at the time of writing; re-check against the version you run.

## gsap-motion


- greensock/gsap-skills (official GSAP agent skills), MIT, Copyright (c) 2026 GreenSock. Taken: the core, timeline, scrolltrigger, plugins, utils, react, frameworks and performance skills, split into `references/*.md` (text kept close to the originals; skill-name cross-references rewritten to file names). The upstream `gsap-scrolltrigger` skill is merged into `references/scrolltrigger.md` (its former four split parts were identical in content and are replaced by that single file; the "When to Use" paragraph and related-skills pointer were restored there).
- `references/install-esm.md`, `tips.md`, `tips-2.md`: install/ESM and best-usage notes; where a source line is given in the file (e.g. the Lenis ScrollTrigger section from darkroomengineering/lenis) it is kept.
- GSAP library itself: GSAP Standard License (see SKILL.md).

## hallmark-design-direction


- Upstream: https://github.com/Nutlope/hallmark (MIT).
- Taken: the anti-template doctrine (the Floor, Reflex gates, Finish checks), shape and theme catalogues, genre voices, craft, interaction and responsive notes, brand-truth and DESIGN.md contract, distilled in the distiller's own words.
- Not taken: the upstream CLI, linter, hooks, image generation and font CDN steps; 8 upstream reference files were not distilled.
- Local changes: brand-colour lookup is a data-only read after asking the user once, https only, private/loopback/metadata addresses refused, fetched text treated as untrusted; the eyebrow-rule contradiction was fixed.

## hallmark-redesign-review


- Upstream: https://github.com/Nutlope/hallmark (MIT); the review-hero, review-finish and redesign skills.
- Taken: fresh-context hero and finish reviews, and the redesign/audit protocol, distilled in the distiller's own words.
- Local changes: reviews are read-only; a redesign needs the user's approval before files are deleted or replaced; committing or stashing is left to the user.
- Companion: loads gate files from the `hallmark-design-direction` skill; install both together.

## harness2-deterministic-script-and-hook-guard


- Origin: compendium `Agentic_Skills_Google_Harness2_SelfEvolving_and_Local_40GB_Agent_Skills.md`, heading "Skill 2: `harness2-deterministic-script-and-hook-guard`", based on video #40 (Pico AI Lab, Google Harness2), the paper the compendium names as arXiv 2610.14224v1, and the demos of video #37 (The Dark Factory) and video #39 (Shaown Ships AI). No license stated for the skill text.
- Taken: script-offloading rule (tables, money, formats, pixel comparison), watchdog step budget, deliverable completion gate, contradiction halt.
- Changed: hooks are described, never created or installed; the pixel threshold is an example from the user's brief; token and benchmark figures removed (unverified); writes to a fixed home-directory path removed.

## harness2-propose-probe-compose


- Origin: compendium `Agentic_Skills_Google_Harness2_SelfEvolving_and_Local_40GB_Agent_Skills.md`, heading "Skill 1: `harness2-propose-probe-compose`", summarising video #40 "Google Harness2 Explained: Cut Enterprise AI Costs With Self-Evolving Agents" (channel Pico AI Lab) and the paper/repository the compendium names as `google-research/harness2` (arXiv 2610.14224v1). The compendium states no license for the skill text.
- Taken: the three-stage propose/probe/compose method, the two diagnosing viewpoints, evidence-gated merging, separate solver/judge, second-level distillation, the failure modes the source lists.
- Changed: approval gates for runs, scratch copies only, no edits to live skills, instruction files, settings or hooks, no write to a fixed home-directory path, accuracy and benchmark figures removed (not verified), model-family wording made generic.

## head-start


- Origin: compendium `Agentic_Skills_Wayfinder_Unlazy_HeadStart_AstryxMax_UIUXProMax_and_BorisCherny.md`, heading "3.1 `head-start`", from video #48 "This Claude Code Skill make Building 10x Faster" (channel AI LABS); the paper-reading method is also described in section 3 of `Research_Papers_FPGA_PyTorch_to_Verilog_Compiler_NeuroArXiv_and_SkillSpector_30K_Study.pdf`. The compendium names two parts, `advise-project-approach` and `neuro-arxiv`, and states no license or upstream location for them.
- Taken: greenfield/brownfield classification, star-count scepticism, three-stage cost model, one fresh-context reader per paper, cross-paper synthesis.
- Changed: price facts must be sourced and dated; no installs; the user trims the paper list and approves a prototype; parallel readers capped; papers treated as untrusted data.

## higgsfield


- `higgsfield-ai/skills` (MIT): selection logic, workflow ideas (generate, soul-id, product-photoshoot, marketplace-cards, youtube-thumbnail, video-explainer, brandkit) and prompt engineering distilled into `references/workflows.md`, `references/prompting-video.md` and the CLI section of `references/cli.md`.
- docs.higgsfield.ai model pages: endpoint paths and parameters in `references/models.md` and `references/models-video.md` (entries marked `[docs]`).

## infra-as-code


- DiegoBulhoes/claude (MIT): `iac/terraform`, `iac/ansible`, `iac/iac-review`, `kubernetes/kubernetes`, `kubernetes/helm`, `kubernetes/kustomize`, `kubernetes/gitops`. Repo-specific paths, credentials, hostnames and registry-MCP tool names were dropped.
- wshobson/agents `kubernetes-operations/k8s-security-policies` (MIT, Seth Hobson). PodSecurityPolicy (removed in Kubernetes 1.25) was replaced by Pod Security Admission.

## landing-copy-voice


- Upstream: https://github.com/Leonxlnx/taste-skill (MIT, (c) 2026 Leonxlnx); the copy modules.
- Taken: the approach to page copy (fact sheet, voice card, device budget, rules, registers, section moves, model tells, over-correction check). All examples are written for this skill.
- Local changes: placeholder hours or prices only with the user's approval and listed in the report; web searching a brand name only with approval; an unverifiable "professional sites" claim was removed.

## legal


Distilled from Anthropic's `claude-for-legal` (Apache-2.0): commercial-legal (`nda-review`, `vendor-agreement-review`, `saas-msa-review`) and privacy-legal (`dpa-review`, `dsar-response`, `pia-generation`, `use-case-triage`). Rewritten; plugin configuration, practice-profile, connector and CLM steps removed; changes made; no endorsement implied. The upstream library is not bundled.

Output of this skill is not legal advice; see the disclaimer at the top of `SKILL.md`.

## marketing


Distilled and rewritten into own words from:
- coreyhaines31/marketingskills (MIT): most references (positioning, copywriting, CRO, SEO, email, launch, pricing, offers, A/B testing, analytics, customer research, competitors, marketing plan).
- sergebulaev/linkedin-skills (MIT): linkedin.md, linkedin-hooks.md, linkedin-profile-planning.md.
- alirezarezvani/claude-skills (MIT), c-level-advisor/chief-of-staff: decision-synthesis.md.
Each reference file carries its own source line. Paid-tool stacks and vendor scripts from the sources were not imported.

## media-generation


- anthropics/skills, Apache-2.0 (https://github.com/anthropics/skills): `canvas-design` (process distilled and reworded into `references/canvas-design.md`), `slack-gif-creator` (helpers copied unchanged to `scripts/slack_gif/core/`; license `scripts/slack_gif/LICENSE.txt`), `algorithmic-art` (method reworded into `references/algorithmic-art.md`). License copy: `assets/LICENSE-anthropics-skills-Apache-2.0.txt`.
- Image/video prompting techniques in `references/prompt-images.md` and `references/prompt-videos.md` are distilled from public Replicate blog posts on current image/video models; condensed and model-agnostic.
- `references/comfyui.md` cites the Comfy-Org/comfy-cli README for commands.
- Removed from this redistribution: the canvas font files and their SIL OFL license files (no fonts are bundled; use installed or system fonts).

## monorepo-nx-turbo


Distilled (not copied verbatim); each reference file keeps its attribution comment on line 1.

- `nrwl/nx-ai-agents-config` (MIT, Nrwl): nx-workspace, nx-run-tasks, nx-generate, nx-plugins, link-workspace-packages, nx-import (-> `references/nx-explore-run.md`, `nx-generate-link.md`, `nx-import-1.md`, `nx-import-2.md`). Nx Cloud skills deliberately excluded.
- `vercel/turborepo` skills/turborepo (MIT, Vercel): `references/turborepo.md`.
- `wshobson/agents` monorepo-management, nx-workspace-patterns, turborepo-caching (MIT, Seth Hobson): `references/pnpm-workspaces.md`, `nx-config-patterns.md`, `turborepo.md`.

## motion


- motiondivision/ai-kit (Motion AI Kit), MIT, commit 1e42494: best-practices, react, css-spring, insert, performance-audit, review, search-docs and transition-preview references are adapted from its skills/agents for any coding agent; paid Motion+ methodology is not reproduced.
- https://motion.dev/docs pages (react-animation, react-layout-animations, react-animate-presence, react-reduce-bundle-size, react-motion-config, react-accessibility, react-use-scroll, react-upgrade-guide, stagger, spring, css, ai-kit): researched into tips.md, tips-2.md, tips-3.md.
- Motion library: MIT. Motion+ (`motion-plus`) is a separate paid package and is not included.

## office-docs


- `nextlevelbuilder/ui-ux-pro-max-skill` (MIT): slide strategy, layout and copywriting material, condensed and rewritten in `references/html-slides.md` and `references/html-slides-content.md`.
- Other references are original workflow notes built on open-source libraries (python-docx, python-pptx, pptxgenjs, openpyxl, pandas, pypdf, pdfplumber, pypdfium2, ReportLab, pandoc, LibreOffice, Ghostscript, qpdf, OCRmyPDF, Typst, MarkItDown). No third-party proprietary skill text or scripts are included.

## plan-and-design


References in this skill are distilled (restated, not copied verbatim) from these upstream projects, all MIT-licensed per the attribution lines in each reference file:

- mattpocock/skills (grilling, domain-modeling, to-spec, to-tickets, wayfinder, handoff, prototype, codebase-design, improve-codebase-architecture)
- obra/superpowers (brainstorming, writing-plans)
- EveryInc compound-engineering-plugin (ce-brainstorm, ce-plan, ce-handoff)
- DiegoBulhoes/claude (prd, tech-spec)
- affaan-m/ecc (blueprint, architecture-decision-records, change-impact)
- wshobson/agents (architecture-decision-records)
- garrytan/gstack (plan-eng-review, plan-ceo-review, office-hours; telemetry and state helpers dropped)

Merged skills:
- `grill-me` (a stub that only delegated to a "grilling" skill from mattpocock/skills): folded into the existing Grill ceremony in `SKILL.md`; nothing copied.
- `ticket-spec-writer`: its rd/eval/board file split is in `references/ticket-files.md` (method restated; no upstream license).

## railway


Distilled and rewritten from railwayapp/railway-skills `use-railway` (MIT), per the attribution lines in `SKILL.md` and `references/analyze-db.md`. Upstream analysis scripts and the auto-approve hook are intentionally not included (see `SKILL.md` core rules).

## research


- `scripts/last30days/`: pruned, free-sources-only subset of mvanhorn/last30days-skill v3.28.0 (MIT, Matt Van Horn). Licence text in `scripts/last30days/LICENSE`; changes listed in `scripts/last30days/VENDORED.md`. The driver `last30days.py` is new.
- `references/item-matrix.md`: pattern adapted from Weizhena/Deep-Research-skills (MIT).
- `references/academic.md`: method restated in own words from the structure of Imbad0202/academic-research-skills (CC BY-NC 4.0; no text copied; non-commercial upstream licence).
- `references/citation-verification.md`, `references/last30days*.md`: original; reference the arxiv-mcp-server tool list (blazickjp/arxiv-mcp-server) by name only.

## security-review


Reference files are condensed and rewritten (no code copied) from:

- trailofbits/skills (CC-BY-SA-4.0, https://github.com/trailofbits/skills): `agentic-actions-auditor` (ci-agent-vectors-1/2), `differential-review` and `audit-context-building` (diff-review), `fp-check` (fp-check), `insecure-defaults` (insecure-defaults), `sharp-edges` (threat-modeling-stride). Those adaptations are shared under CC-BY-SA-4.0, as stated in each file header.
- affaan-m/ecc (MIT): `security-review`, `agent-security-hardening`, `mcp-dependency-review`.
- wshobson/agents (MIT): `auth-implementation-patterns`, `stride-analysis-patterns`.
- garrytan/gstack (MIT): `cso` evidence rubric idea.
- A `security-and-hardening` skill (no license text seen in the files).

## site-visual-direction


- Upstream: https://github.com/Leonxlnx/taste-skill (MIT, (c) 2026 Leonxlnx); the visuals modules.
- Taken: the picture-plan approach (inventory, picture by kind, sourcing order, grounds, effects, report), described in prose. None of the upstream components, backgrounds, effects or scripts are copied or run.
- Local change: searching for and downloading third-party photos or icon sets requires the user's approval.

## skill-authoring


References are distilled (restated, not pasted) from, per the attribution lines in each reference file:

- mattpocock/skills (MIT): writing-for-agents
- obra/superpowers (MIT): writing-skills
- anthropics/skills (Apache-2.0): skill-creator
- EveryInc/compound-engineering-plugin (MIT): ce-skill-work, ce-retune
- tigerless-labs/autoharness (MIT): learn
- garrytan/gstack (MIT): skillify
- affaan-m/ecc (MIT): skill-stocktake, rules-distill, skill-scout
- vercel-labs/skills (MIT): find-skills
- mrclrchtr/supi (MIT): claude-md-improver, claude-md-revision
- A third-party skill-scanner skill (no license file shipped) and the NVIDIA SkillSpector v2.12.0 CLI (behavior only): adoption-scan-1/2

`scripts/check_skill.py` is original to this skill.

## skill-quality-gates


- Upstream: NVIDIA SkillEvaluator (https://github.com/NVIDIA/SkillEvaluator), Apache-2.0. Taken: tier1-reference and metrics-reference criteria (`references/frontmatter-and-portability.md`, `references/quality-rubric.md`) and the eval-datasets method (`references/eval-design.md`), distilled. The evaluator CLI and Harbor runner are not used.
- Upstream: NVIDIA SkillSpector (https://github.com/NVIDIA/SkillSpector), `skills/skill-inspector`, Apache-2.0. Taken: the adoption verdict rubric, semantic review questions and score posture (`references/adoption-verdict.md`). The `skillspector` CLI is optional and never required.
- Harness figures in the portability reference are the upstream docs' values at the time of writing and drift with harness releases.

## stageshow


- Upstream: https://github.com/benjitaylor/skills (MIT, Benji Taylor; stageshow package, MIT per its own LICENSE file).
- Taken: the design doctrine for miniature product UI (framing, craft, motion, verification), written in the distiller's own words.
- Not taken: the upstream React kit, gold examples, film scripts and capture scripts. Build every part yourself; do not claim a kit part exists.

## stripe


Condensed and rewritten from stripe/ai (MIT): `stripe-best-practices` (references billing, connect, payments, security, tax, treasury) and `upgrade-stripe`. Fact snapshots are dated 2026-10-18 in the files and must be verified live.

## supply-chain-audit


Scripts (`scripts/*.py`, `scripts/pyproject.toml`) and method come from trailofbits/skills `supply-chain-risk-auditor` (CC-BY-SA-4.0, https://github.com/trailofbits/skills). The scripts are shipped unmodified; `SKILL.md` and `references/interpreting-results.md` are condensed, cross-platform adaptations shared under CC-BY-SA-4.0.

## swift-modern-language


- Upstream: emilkowalski/skills (https://github.com/emilkowalski/skills), MIT, Copyright 2026 Emil Kowalski.
- Taken: the `write-swift` skill, distilled into `SKILL.md` and the three reference files (`concurrency.md` from sections 3-6, `types-api-performance.md` from sections 1, 2 and 7-10, `testing-syntax-migration.md` from sections 11-16).
- Edits: unreleased Swift 6.4 items are flagged as unreleased, not asserted; a pointer to a skill that is not part of this collection was removed.

## taste-art-direction-gate


- Upstream: leonxlnx/taste-skill (https://github.com/Leonxlnx/taste-skill), MIT, (c) 2026 Leonxlnx.
- Taken: the gate, system, layout, motion, moments and perf guidance, distilled into `SKILL.md` and the `references/` files (each reference keeps a "Distilled from" header). No kit files, scripts or assets are used.
- Dropped: the upstream `hooks: Stop` command (it ran a node script), the hook installer docs, the node scripts and any asset copying.
- Added locally: picking reference sites needs the user's approval; the assumed-facts exception follows the `landing-copy-voice` skill.

## ui-design


Per the licence line in `SKILL.md` and each reference file:

- impeccable playbooks (`references/impeccable/`): Apache-2.0 (pbakaus)
- Emil Kowalski motion and craft (`references/emil/`): emilkowalski/skills, MIT
- `references/quick-fixes*.md`: ibelick/ui-skills, MIT
- `scripts/search.py` and `scripts/data/*.csv` (per `references/stacks.md`; the other helper scripts of the same search tool are `core.py`, `design_system.py`, `reasoning_contract.py`): nextlevelbuilder/ui-ux-pro-max-skill, MIT (licence in `scripts/LICENSE-ui-ux-pro-max.txt`); `core.py` modified on one line (`DATA_DIR`)
- `references/aesthetic-direction.md`: condensed from the Anthropic frontend-design skill, Apache-2.0
- `references/web-artifact-bundle.md`: idea from anthropics/skills web-artifacts-builder, Apache-2.0 (rewritten as a manual recipe)

## ui-variant-prototyping


- Upstream: emilkowalski/skills (https://github.com/emilkowalski/skills), MIT, Copyright 2026 Emil Kowalski.
- Taken: the `prototype` skill, re-expressed in own words; `references/picker-spec.md` distills its variant switcher values (follow the values, not any exact upstream markup).
- Added locally: prototypes stay away from production code until the user picks; no push, deploy or publish; only the skill's own files are deleted.

## unlazy-parallel


- Origin 1: compendium `Agentic_Skills_Wayfinder_Unlazy_HeadStart_AstryxMax_UIUXProMax_and_BorisCherny.md`, heading "2.2 `unlazy-parallel`", from video #47 "GitHub's #1 Trending Author's New Claude Skill Is Insane" (channel AI LABS). The compendium says it modifies the project it names as `Leonxlnx/unlazy` (author of `taste-skill`) to run leaf tasks in parallel; it states no license for the modified text and the upstream text was not available here. Background on the laziness problem: `Research_Papers_FPGA_PyTorch_to_Verilog_Compiler_NeuroArXiv_and_SkillSpector_30K_Study.pdf`, section 3 (summary only).
- Origin 2 (`references/subtask-manifest.md`): same compendium, heading "3.2 `handoff`", from video #51 "Fleet Engineering Is Insane... The Next Evolution Of Vibe Coding" (channel AI LABS).
- Taken: depth-N tree with leaves of real work, file-ownership plan, command/expected/evidence ledger, no self-grading, give-up rule, per-session manifest fields.
- Changed: the external checker script is not shipped (run commands yourself or via CI); folder creation and ledger approval gated on the user; gate commands restricted to non-destructive local/test; "agent fraud" wording and the fixed 10-agent figure removed; launch commands for specific products removed.

## vercel-deploy


- `vercel-labs/agent-skills` (MIT): deploy-to-vercel, vercel-cli-with-tokens and vercel-optimize, distilled into `references/cli-token-auth.md`, `references/optimize-playbook.md`, `references/optimize-topics.md` and `references/framework-notes.md`. The anonymous/claimable deploy scripts, `.env` token scraping and `--token` usage were removed on purpose.

## vercel-next-react


Distilled and rewritten (not copied verbatim); each reference keeps its attribution on line 3.

- `vercel-labs/agent-skills` react-best-practices, composition-patterns, react-view-transitions (MIT, Vercel Engineering): `references/react-rules-critical.md`, `react-rules-more.md`, `composition-patterns.md`, `view-transitions.md`.
- `vercel/next.js` skills next-dev-loop, next-bundle-optimizer, next-cache-components-adoption/optimizer, next-partial-prefetching-adoption/optimizer (MIT): `references/next-dev-loop.md`, `next-bundle-optimizer.md`, `next16-cache-components.md`, `next16-partial-prefetching.md`.
- `wshobson/agents` nextjs-app-router-patterns, react-state-management, tailwind-design-system, react-modernization (MIT): `references/app-router-ecosystem.md`.
- `affaan-m/ecc` nextjs-turbopack (MIT): parts of `references/next-build-hosting.md`, `next-routing-errors.md`.
- `vercel-labs/next-skills` next-best-practices (license not stated in the files; content rewritten in own words): `references/next-assets-metadata.md`, `next-build-hosting.md`, `next-routing-errors.md`, `next-rsc-data.md`.

## wayfinder-answer-key


- Origin: compendium `Agentic_Skills_Wayfinder_Unlazy_HeadStart_AstryxMax_UIUXProMax_and_BorisCherny.md`, heading "2.1 `wayfinder-answer-key`", from video #46 "This Claude Skill Just Fixed Loop Engineering" (channel AI LABS). The compendium says it modifies the `/wayfinder` and `/grill-me` skills of the repository it names as `mattpocock/skills`; it states no license for the modified text and the upstream text was not available here.
- Taken: fog identification, the two files (`map.md`, `answer-key.md`), critics graded only against the answer key, builders given the map.
- Changed: folder creation, approval of both files and an amendment rule added; a reference bar and a round cap added; critics at least as strong as builders; checks limited to local or test environments.

## web-platform-behavior-checks


- Upstream: vercel-labs/agent-browser (https://github.com/vercel-labs/agent-browser), `skill-data/modern-web-guidance`, Apache-2.0.
- Taken: the rule-to-browser-check method and the probes for layout shift, reduced motion, color scheme and modal dialog, rewritten as plain Playwright snippets in `references/checks.md`.
- Not taken: the upstream agent-browser and modern-web-guidance CLIs; the `npx modern-web-guidance@latest` command was dropped.
- Added locally: the dialog probe runs against a local server with test data only, with a harmless trigger and a harmless background link.

## web-quality


Distilled and rewritten (not copied verbatim); each reference keeps its attribution on line 3.

- `addyosmani/web-quality-skills` (MIT): `references/cwv.md`, `performance.md`, `seo-structured-data.md`, `best-practices-security.md`, `accessibility-wcag.md`, `screen-reader-testing.md`.
- `wshobson/agents` wcag-audit-patterns and screen-reader-testing (MIT): `references/accessibility-wcag.md`, `screen-reader-testing.md`.

## web-testing


- `anthropics/skills` webapp-testing (Apache-2.0): `scripts/with_server.py` is adapted from its `with_server.py` (changes listed in the script docstring: no shell, per-server cwd, log files, process-tree cleanup, fail-fast). Apache-2.0 notice retained in the script header; method notes in `references/playwright-suite.md` and `references/browser-qa-method.md`.
- `EveryInc/compound-engineering-plugin` ce-test-browser and ce-dogfood (MIT), `garrytan/gstack` qa (MIT): `references/browser-qa-method.md`.
- `affaan-m/ecc` e2e-testing (MIT), `wshobson/agents` e2e-testing-patterns (MIT): `references/playwright-suite.md`.
- `affaan-m/ecc` react-testing (MIT): `references/react-testing.md`.
- Other reference files keep their own attribution line at the top.

## writing-clarity


- `hardikpandya/stop-slop` (MIT, Copyright (c) 2025 Hardik Pandya): `references/stop-slop/*` copied verbatim; attribution header kept in each file.
- `danyuchn/asd-ste100-skill` (MIT, Copyright (c) 2026 Dustin Yuchen Teng): `references/ste100/*` copied verbatim (header kept) and `scripts/ste-lint.py` copied unchanged; licence text in `scripts/LICENSE-ste-lint.txt`.
- `anthropics/skills` doc-coauthoring (Apache 2.0): distilled and rewritten into `references/coauthoring.md`.
- `sergebulaev/linkedin-skills` linkedin-humanizer (MIT): distilled and rewritten in own words into `references/linkedin-patterns.md`.
- Vale config and rules in `references/vale/` and `references/vale.md`: local additions.

