<!-- Derived from core/skills/catalog.json — edit the catalog, not this list. -->
# Skills catalog

`universal-agentic-setup` ships **zero vendored skills** — it ships a *curated catalog*
and installs skills on demand with the de-facto standard package manager
([vercel-labs/skills](https://github.com/vercel-labs/skills) `npx skills` CLI), which
knows the install location of 80+ agents.

Counts below are computed from [`core/skills/catalog.json`](../core/skills/catalog.json):
**21 core · 14 optional · 9 rejected**.

## Install

```bash
# everything in the core tier (dry-run prints the commands by default):
python3 scripts/agentic_sync.py --skills --apply

# one skill, explicitly:
npx skills add anthropics/skills --skill pdf -g -y
```

`-g` installs user-scope (e.g. `~/.claude/skills`, `~/.agents/skills`); project-scope
installs drop the flag. Skills are installed from their upstream repositories —
upstream licenses apply (the three Anthropic document skills are source-available:
installed from source, never redistributed here).

## Tier: core (21) — installed by default

Vetting bar: official vendor or top-reputation author, knowledge-first, skills.sh
Gen/Socket/Snyk audits reviewed, local red-flag scan.

| Set | Skill | Source | Why |
|---|---|---|---|
| authoring | skill-creator | anthropics/skills | Canonical workflow to author, test and package Agent Skills. |
| authoring | mcp-builder | anthropics/skills | Official guide for building MCP servers (tool naming, schemas, evals). |
| engineering | systematic-debugging | obra/superpowers | Root-cause-first debugging method; most adopted engineering skill set. |
| engineering | grill-me | mattpocock/skills | User-invoked requirements interrogation before building. |
| security | skill-scanner | getsentry/skills | Audits third-party skills before/after install. |
| security | security-and-hardening | addyosmani/agent-skills | Threat-model-first web hardening incl. privacy compliance (GDPR/CNDP-style). |
| web-research | build-with-exa | exa-labs/agent-skills | Official Exa API reference. **Requires `EXA_API_KEY` for live API calls.** |
| documents | pdf | anthropics/skills | PDF extract/merge/forms/OCR via local Python scripts. |
| documents | docx | anthropics/skills | Word create/edit incl. tracked changes. |
| documents | xlsx | anthropics/skills | Excel generation with formulas/formatting. |
| documents | convert-documents-to-markdown | firecrawl/anydoc | Local DOC/DOCX/PPT/XLS/PDF/EPUB → Markdown via anydoc (npx at use time). |
| frontend | frontend-design | anthropics/skills | Art-directed UI instead of generic AI defaults. |
| frontend | gsap-scrolltrigger | greensock/gsap-skills | Official GSAP ScrollTrigger guidance for scroll-telling. |
| devops | docker-compose-patterns | docker/skills | Official Docker compose wiring/debugging patterns. |
| devops | docker-build-strategies | docker/skills | Official Dockerfile build strategies. |
| data | supabase-postgres-best-practices | supabase/agent-skills | Vendor-neutral Postgres schema/RLS/index/perf guidance. |
| knowledge | obsidian-markdown | kepano/obsidian-skills | Valid Obsidian-flavored Markdown (wikilinks, callouts, properties). |
| media | remotion-best-practices | remotion-dev/skills | Official programmatic-video (React) guidance; renders locally, no media API. |
| media | prompt-videos | replicate/skills | Model-agnostic video prompting guide (knowledge only; no token needed). |
| media | prompt-images | replicate/skills | Model-agnostic image prompting guide (knowledge only; no token needed). |
| models | hf-cli | huggingface/skills | Official Hugging Face Hub CLI reference. |

## Tier: optional (14) — opt-in, each with a reason it is not core

| Set | Skill | Source | Caution / requirement |
|---|---|---|---|
| security | supply-chain-risk-auditor | trailofbits/skills (CC-BY-SA-4.0) | Its scripts read the GitHub token via `gh auth token`; only enable where that token's scopes are acceptable. |
| frontend | web-design-guidelines | vercel-labs/agent-skills | Fetches its guideline document from a URL at run time (remote instructions). |
| browser | agent-browser | vercel-labs/agent-browser | Needs `npm i -g agent-browser && agent-browser install` (downloads Chromium). |
| media | hyperframes | heygen-com/hyperframes | npm CLI; HeyGen cloud render/providers are paid and optional. |
| media | h3-prompt-writing | MiniMax-AI/MiniMax-H3 | — |
| prompting | promptify | intellectronica/agent-skills | Prompt-rewriting skill: review before trusting. |
| prompting | prompt-engineering-patterns | wshobson/agents | — |
| web-research | firecrawl | firecrawl/cli | Needs a Firecrawl account or self-hosted server. |
| models | gemini-api-dev | google-gemini/gemini-skills | Media endpoints on the Gemini API are paid. |
| sessions | cass | Dicklesworthstone/coding_agent_session_search | Needs the cass binary; indexes full transcripts locally (may contain secrets) — keep the index local. |
| mesh | agent-mesh-coordinator | ruvnet/ruflo | References ruflo runtime tools other agents may not have. |
| mesh | a2a-cli | a2aproject/a2a-cli | Very new, thin adoption. |
| voice | text-to-speech | elevenlabs/skills | Needs `ELEVENLABS_API_KEY`; effectively paid. |
| knowledge | obsidian-cli | kepano/obsidian-skills | Can eval JS inside the app (Gen audit Warn). |

## Tier: rejected (9) — researched and declined; kept so nobody re-adds them

| Source | Reason |
|---|---|
| 101-skills/superpowers | Name-squatting fork of obra/superpowers with install counts far above its 5 stars (likely farmed); Socket Warn; routes media through a paid CLI. |
| llllllma/rigorpilot-skills | Anomalous near-identical install counts across skills; Snyk Warn; niche. |
| inference-sh/skills | Paid middleman for models reachable directly; fork-network install inflation. |
| theplasmak/faster-whisper | Two of three skills.sh audits fail; use openclaw openai-whisper or faster-whisper directly. |
| trailofbits/skills `insecure-defaults` | Instructs quoting credential values as evidence, landing secrets in transcripts (Snyk W007). |
| bitwarden/agent-access | Surfaces plaintext secrets into the agent transcript by design (Snyk W007). |
| ComposioHQ/awesome-claude-skills (vendored skills) | Drifting copies of official skills inside a lead-gen funnel; install officials instead. |
| juliusbrussee/caveman | Terse-speak gimmick; degrades nuanced output. |
| BloopAI/vibe-kanban | Company shut down 2026-04-10; local edition community-maintained only. |

## Agent skill-directory cheat sheet

Most 2026 agents read the cross-agent dirs `~/.agents/skills` (user) and
`.agents/skills` (project) — see [AGENTS-MATRIX.md](AGENTS-MATRIX.md) for the exact
per-agent list (Claude Code `~/.claude/skills`, Codex `~/.codex/skills`, Gemini
`~/.gemini/skills`, Cursor `~/.cursor/skills`, Amp `~/.config/agents/skills`, …).
