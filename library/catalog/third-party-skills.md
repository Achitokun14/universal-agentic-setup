# Catalogue of third-party skills that are NOT bundled

These exist on the maintainer's machines but are third-party packs with their own licences or unknown provenance, so they are listed, not redistributed.
Install a listed skill from its upstream source. Group names are heuristic (derived from skill names); `covered by` means a bundled skill already contains that area.

## A. Skills installed through the `skills` CLI (source known)

| skill | upstream | status | licence | install |
|---|---|---|---|---|
| grill-me | mattpocock/skills | merged into plan-and-design (stub) | see upstream repository | `npx skills add mattpocock/skills --skill grill-me` |
| docx | anthropics/skills | catalog only | proprietary (all rights reserved) - never redistributed | `npx skills add anthropics/skills --skill docx` |
| frontend-design | anthropics/skills | catalog only | see upstream repository | `npx skills add anthropics/skills --skill frontend-design` |
| mcp-builder | anthropics/skills | catalog only | see upstream repository | `npx skills add anthropics/skills --skill mcp-builder` |
| pdf | anthropics/skills | catalog only | proprietary (all rights reserved) - never redistributed | `npx skills add anthropics/skills --skill pdf` |
| skill-creator | anthropics/skills | catalog only | see upstream repository | `npx skills add anthropics/skills --skill skill-creator` |
| xlsx | anthropics/skills | catalog only | proprietary (all rights reserved) - never redistributed | `npx skills add anthropics/skills --skill xlsx` |
| build-with-exa | exa-labs/agent-skills | catalog only | see upstream repository | `npx skills add exa-labs/agent-skills --skill build-with-exa` |
| skill-scanner | getsentry/skills | catalog only | see upstream repository | `npx skills add getsentry/skills --skill skill-scanner` |
| systematic-debugging | obra/superpowers | catalog only | see upstream repository | `npx skills add obra/superpowers --skill systematic-debugging` |
| remotion-best-practices | remotion-dev/skills | catalog only | see upstream repository | `npx skills add remotion-dev/skills --skill remotion-best-practices` |
| prompt-images | replicate/skills | catalog only | see upstream repository | `npx skills add replicate/skills --skill prompt-images` |
| prompt-videos | replicate/skills | catalog only | see upstream repository | `npx skills add replicate/skills --skill prompt-videos` |
| hf-cli | huggingface/skills | catalog only | see upstream repository | `npx skills add huggingface/skills --skill hf-cli` |
| docker-build-strategies | docker/skills | merged into docker | see upstream repository | `npx skills add docker/skills --skill docker-build-strategies` |
| docker-compose-patterns | docker/skills | merged into docker | see upstream repository | `npx skills add docker/skills --skill docker-compose-patterns` |
| security-and-hardening | addyosmani/agent-skills | catalog only | see upstream repository | `npx skills add addyosmani/agent-skills --skill security-and-hardening` |
| gsap-scrolltrigger | greensock/gsap-skills | merged into gsap-motion | see upstream repository | `npx skills add greensock/gsap-skills --skill gsap-scrolltrigger` |
| obsidian-markdown | kepano/obsidian-skills | catalog only | see upstream repository | `npx skills add kepano/obsidian-skills --skill obsidian-markdown` |
| supabase-postgres-best-practices | supabase/agent-skills | catalog only | see upstream repository | `npx skills add supabase/agent-skills --skill supabase-postgres-best-practices` |
| convert-documents-to-markdown | firecrawl/anydoc | catalog only | see upstream repository | `npx skills add firecrawl/anydoc --skill convert-documents-to-markdown` |

## B. Other third-party skills found locally (337 listed, 19 owner-specific entries withheld)

### UI / design (15)
Covered by bundled skill(s): `ui-design`.

`brutalist-skill`, `design-system`, `emil-design-eng`, `impeccable`, `minimalist-skill`, `od-shadcn-ui`, `platform-design`, `redesign-skill`, `soft-skill`, `taste-skill`, `theme-factory`, `ui-modernize`, `ui-skills`, `ui-ux-pro-max`, `web-design-guidelines`

### agent orchestration (18)
Covered by bundled skill(s): `agent-topology-chooser`.

`agent-bridge`, `agent-coordination`, `agent-eval`, `agent-goal-planner`, `agent-harness-construction`, `agent-introspection-debugging`, `agent-orchestrator-task`, `agent-sort`, `autonomous-agent-harness`, `autonomous-loops`, `claude-devfleet`, `continuous-agent-loop`, `continuous-learning`, `continuous-learning-v2`, `coordinator-orchestrator`, `dmux-workflows`, `hive-mind`, `swarm-orchestration`

### caveman family (5)

`caveman`, `caveman-commit`, `caveman-compress`, `caveman-help`, `caveman-review`

### databases (2)

`database-migrations`, `postgres-patterns`

### docker (1)
Covered by bundled skill(s): `docker`.

`docker-patterns`

### gstack family (46)

`gstack-autoplan`, `gstack-benchmark`, `gstack-benchmark-models`, `gstack-browse`, `gstack-canary`, `gstack-careful`, `gstack-codex`, `gstack-connect-chrome`, `gstack-context-restore`, `gstack-context-save`, `gstack-cso`, `gstack-design-consultation`, `gstack-design-html`, `gstack-design-review`, `gstack-design-shotgun`, `gstack-devex-review`, `gstack-document-release`, `gstack-freeze`, `gstack-gstack-upgrade`, `gstack-guard`, `gstack-health`, `gstack-investigate`, `gstack-land-and-deploy`, `gstack-landing-report`, `gstack-learn`, `gstack-make-pdf`, `gstack-office-hours`, `gstack-open-gstack-browser`, `gstack-pair-agent`, `gstack-plan-ceo-review`, `gstack-plan-design-review`, `gstack-plan-devex-review`, `gstack-plan-eng-review`, `gstack-plan-tune`, `gstack-qa`, `gstack-qa-only`, `gstack-retro`, `gstack-review`, `gstack-scrape`, `gstack-setup-browser-cookies`, `gstack-setup-deploy`, `gstack-setup-gbrain`, `gstack-ship`, `gstack-skillify`, `gstack-sync-gbrain`, `gstack-unfreeze`

### language/framework patterns (15)

`ai-regression-testing`, `api-design`, `backend-patterns`, `coding-standards`, `deployment-patterns`, `frontend-patterns`, `golang-patterns`, `golang-testing`, `mcp-server-patterns`, `nestjs-patterns`, `nuxt4-patterns`, `python-patterns`, `python-testing`, `rust-patterns`, `rust-testing`

### marketing / growth (41)
Covered by bundled skill(s): `marketing`.

`ab-test-setup`, `ad-creative`, `ai-seo`, `analytics-tracking`, `article-writing`, `brand-voice`, `churn-prevention`, `cold-email`, `community-marketing`, `competitor-alternatives`, `content-engine`, `content-hash-cache-pattern`, `content-strategy`, `copy-editing`, `copywriting`, `crosspost`, `email-sequence`, `form-cro`, `launch-shadcn-registry`, `launch-strategy`, `lead-intelligence`, `lead-magnets`, `marketing-ideas`, `marketing-psychology`, `onboarding-cro`, `page-cro`, `paid-ads`, `paywall-upgrade-cro`, `popup-cro`, `pricing-strategy`, `product-marketing-context`, `programmatic-seo`, `referral-program`, `revops`, `sales-enablement`, `schema-markup`, `seo`, `seo-audit`, `signup-flow-cro`, `site-architecture`, `social-content`

### other (109)

`accessibility`, `agentic-engineering`, `ai-slop-cleaner`, `api-connector-builder`, `architecture-decision-records`, `ask`, `aso-audit`, `autoresearch`, `beautiful_prose`, `benchmark`, `brag`, `browser`, `browser-harness`, `bun-runtime`, `canary-watch`, `cancel`, `chronology`, `ck`, `claude-api`, `code-tour`, `codebase-onboarding`, `configure-notifications`, `context-budget`, `context-engineering-skills`, `continue-loop`, `cost-aware-llm-pipeline`, `council`, `dashboard-builder`, `data-scraper-agent`, `debug`, `deploy-runbook`, `deploy-verify-loop`, `documentation-lookup`, `dsar-response`, `eval-harness`, `evaluating-llms-harness`, `everything-claude-code`, `exa-search`, `external-context`, `fal-ai-media`, `flue`, `frontend-slides`, `gguf-quantization`, `git-workflow`, `graphify`, `handy`, `headroom`, `hookify-rules`, `hud`, `huggingface-accelerate`, `improve`, `ip-clause-review`, `iterative-retrieval`, `jcode-optimization`, `jira-integration`, `learner`, `linear-claude-skill`, `managing-google-workspace`, `manim-video`, `market-research`, `mcp-setup`, `my-skills`, `nanoppt-skills`, `nextjs-turbopack`, `notebooklm-skill`, `opentofu`, `opentui`, `peft-fine-tuning`, `plan-design-review`, `plankton-code-quality`, `product-capability`, `product-lens`, `project-session-manager`, `prompt-optimizer`, `public-apis`, `pypict-claude-skill`, `ralph`, `react-best-practices`, `recover-skipped`, `reg-gap-analysis`, `regex-vs-llm-structured-text`, `release`, `remember`, `repo-scan`, `review`, `rules-distill`, `ruv`, `santa-method`, `search-first`, `self-improve`, `serving-llms-vllm`, `setup`, `skill`, `skill-comply`, `skill-rails-upgrade`, `skill-stocktake`, `skillify`, `stop-slop`, `strategic-compact`, `tabular-review`, `tdd-workflow`, `terraform-skill`, `token-budget-advisor`, `trace`, `verification-loop`, `verify`, `video-editing`, `wiki`, `writer-memory`

### planning / orchestration (12)
Covered by bundled skill(s): `plan-and-design`.

`autopilot`, `blueprint`, `ccg`, `deep-interview`, `deepinit`, `html-plan`, `plan`, `ralplan`, `team`, `team-builder`, `ultrawork`, `visual-plan`

### plannotator family (3)

`plannotator-annotate`, `plannotator-last`, `plannotator-review`

### ponytail family (6)

`ponytail`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-help`, `ponytail-review`

### railway (12)
Covered by bundled skill(s): `railway`.

`railway-database`, `railway-deploy`, `railway-deployment`, `railway-domain`, `railway-environment`, `railway-metrics`, `railway-new`, `railway-projects`, `railway-railway-docs`, `railway-service`, `railway-status`, `railway-templates`

### research / academic (11)
Covered by bundled skill(s): `research`.

`academic-deep-research`, `academic-paper`, `academic-paper-reviewer`, `academic-pipeline`, `deep-dive`, `deep-research`, `last30days`, `research-deep`, `research-improve`, `research-report`, `sciomc`

### ruflo family (ruvnet/ruflo) (29)

`ruflo-agentdb-advanced`, `ruflo-agentdb-learning`, `ruflo-agentdb-memory-patterns`, `ruflo-agentdb-optimization`, `ruflo-agentdb-vector-search`, `ruflo-agentic-jujutsu`, `ruflo-browser`, `ruflo-flow-nexus-neural`, `ruflo-flow-nexus-platform`, `ruflo-flow-nexus-swarm`, `ruflo-github-code-review`, `ruflo-github-multi-repo`, `ruflo-github-project-management`, `ruflo-github-release-management`, `ruflo-github-workflow-automation`, `ruflo-hive-mind-advanced`, `ruflo-hooks-automation`, `ruflo-pair-programming`, `ruflo-performance-analysis`, `ruflo-reasoningbank-agentdb`, `ruflo-reasoningbank-intelligence`, `ruflo-skill-builder`, `ruflo-sparc-methodology`, `ruflo-stream-chain`, `ruflo-swarm-advanced`, `ruflo-swarm-orchestration`, `ruflo-verification-quality`, `ruflo-worker-benchmarks`, `ruflo-worker-integration`

### security (6)
Covered by bundled skill(s): `security-review`.

`gateguard`, `safety-guard`, `security-bluebook-builder`, `security-bounty-hunter`, `security-code-audit`, `security-scan`

### testing/qa (6)
Covered by bundled skill(s): `web-testing`.

`browser-qa`, `click-path-audit`, `e2e-testing`, `ui-demo`, `ultraqa`, `visual-verdict`

