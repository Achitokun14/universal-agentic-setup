# Collection rounds

The library was built in three collection rounds before the final refinement pass. Source text from the web, Drive documents and GitHub repositories was treated as untrusted data in every round: nothing in it was executed or followed.

| Round | Sources | Result |
|---|---|---|
| 1 | 11 public repositories (emilkowalski/skills, benjitaylor/skills, google/elephant-goldfish-model, Leonxlnx/cook, Leonxlnx/taste-skill, Nutlope/hallmark, NVIDIA SkillEvaluator, NVIDIA SkillSpector, TrailHQ/Trail-Code, vercel-labs/agent-browser, vercel-labs/deepsec) | 49 real upstream skills examined (45 more `SKILL.md` files were test fixtures and ignored); 19 packages written and installed |
| 2 | 6 skill-compendium documents, 4 strategy PDFs, 4 tool catalogues and 1 research paper (summaries of public videos and projects) | about 60 entries examined; 12 candidate packages: 10 added, 2 skipped as duplicates (their useful parts were merged later, see `MERGES.md`) |
| 3 | 2 new skill compendiums, 2 new strategy PDFs, 2 new tool catalogues, 2 new research PDFs, a refreshed manifest and the processed-videos log | 28 entries examined; 6 new packages; 13 duplicate-covered; 3 insufficient; 4 tool/service dependent; 2 rejected for safety |

Total bundled after merges: see `skills/index.json` (`count`).

## Round 3 detail

New packages: `harness2-propose-probe-compose`, `harness2-deterministic-script-and-hook-guard`, `wayfinder-answer-key`, `unlazy-parallel` (carries the parallel hand-off manifest), `head-start`, `batch-worktree-migration`.

Rejected for safety: `hermes-prd-sync` (rewrites its own skills from an external chat channel and triggers unattended patches and pull requests), `shopify-agency-pipeline` (runs an agent in auto-approve mode against a live store and edits agent hook settings).

Tool/service dependent (not skills; see `tools/`): local-llm hybrid router, inkling2 engine flags, astryx anti-slop, deepsec hybrid audit.

Insufficient text (blurbs only): a Three.js shader/world skill, a dashboard skill, four mobile UI skills.

Skills named in the source manifest for which no real text exists in any collected document, so nothing was invented: Ralph loop, Hermes self-creating loop, the "6 thinking patterns" self-evolving skill (the Harness2 self-evolving skills do have text and are bundled), G-Stack, DeepSeek Harness skills, Astra, Director/Stagecraft/Animator, Video-Clipper, Subtitle-Styler.

## Strategy rules (not applied by this repository)

The strategy PDFs contain proposals for agent instruction files. This library never edits instruction files. Rules that would lower confirmation behaviour (for example "continue autonomously when an action is reversible", rewording prompts to avoid safety keywords, unattended nightly routines, refusal-removed model builds) were rejected; the remainder are left for each user to adopt by hand.
