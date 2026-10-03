# Inspirations & Credits

The universal-agentic-setup bundle borrows patterns from 20 high-signal OSS repos and Claude Code community projects. This doc credits each source and explains what was adopted.

## Adopted — bundled directly

| Source | License | Pattern adopted | Where it lives in this bundle |
|--------|---------|-----------------|-------------------------------|
| [obra/superpowers](https://github.com/obra/superpowers) | MIT | Parallel Explore+Plan dispatch pattern; handoff/compress doc | `/pair`, `/compress` commands |
| [garrytan/gstack](https://github.com/garrytan/gstack) | MIT | Role-based slash commands (40+), safety modes | `/careful`, `/freeze`, `/unfreeze`, `/autoplan`, `/retro` |
| [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) | MIT | "Instincts" → persistent `/learn` append to llm-wiki | `/learn` + `memory-compiler.sh` hook |
| [karpathy/llm-wiki](https://github.com/karpathy/llm-wiki) (pattern, not repo) | — | Persistent compounding notes keyed by date | `~/Desktop/ACTIVITIES/llm-wiki/` + `memory-compiler.sh` |
| [google/langextract](https://github.com/google/langextract) | Apache-2.0 | Structured extraction with source grounding | `/extract` command |
| [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp) | Unlicense | Universal video/audio downloader | `/ytdl` + `scripts/ytdl-to-wiki.sh` |
| [getzep/graphiti](https://github.com/getzep/graphiti) | Apache-2.0 | Entity + temporal relationship tracking (lite, no Neo4j) | `entity-tracker.sh` hook + `entities.jsonl` |
| [lightpanda-io/browser](https://github.com/lightpanda-io/browser) | AGPL-3.0 | 16× lighter headless browser for agent use | `scripts/install-lightpanda.sh` (optional MCP install) |

## Adopted — optional clone (Phase A, via `install-inspired.sh`)

User opts in per-source. Each gets cloned to `~/.claude/skills/_inspired/<repo>/` and top-level SKILL.md folders are symlinked into `~/.claude/skills/`.

| Source | Why it's opt-in |
|--------|-----------------|
| [ChristopherKahler/base](https://github.com/ChristopherKahler/base) | Injects JSON surfaces on every UserPromptSubmit — big context footprint |
| [ChristopherKahler/paul](https://github.com/ChristopherKahler/paul) | Per-project `.paul/` directory, 26 slash commands — opt-in per repo |
| [ChristopherKahler/carl](https://github.com/ChristopherKahler/carl) | Keyword-triggered rule injection, low overhead — generally safe |
| [Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) | 19 agents, tmux workers, smart model routing |
| [bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) | 12+ domain-expert agents; "Party Mode" multi-persona |
| [mistarzewski/agency-agents](https://github.com/mistarzewski/agency-agents) | Agency workflow-specific agents |
| [santifier/career-ops](https://github.com/santifier/career-ops) | Personal/job-search tool; opt-in |
| [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | Already installed as skill; cross-check for updates |
| [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | Already installed; cross-check for updates |

## Cross-referenced only — not bundled

| Source | Why not bundled |
|--------|-----------------|
| MiniMax MCP | Already configured in ZeroClaw; avoid double-config |
| [dani-garcia/vaultwarden](https://github.com/dani-garcia/vaultwarden) | Server-side; `scripts/vw-helper.sh` is our thin client instead |
| [volcengine/OpenViking](https://github.com/volcengine/OpenViking) | Docs mostly non-English at time of writing; revisit later |
| [p-e-w/heretic](https://github.com/p-e-w/heretic) | Unclear scope at time of writing; revisit |
| [zakirkun/deep-eye](https://github.com/zakirkun/deep-eye) | Security scanner requires explicit authorization per engagement; too vertical for default install |
| full [getzep/graphiti](https://github.com/getzep/graphiti) | Requires Neo4j/FalkorDB/Kuzu + LLM API key — too heavy for personal bundle. See `entity-tracker.sh` (graphiti-lite) |

## License compliance

- Everything adopted in this bundle is MIT/Apache-2.0/Unlicense — compatible with personal use and redistribution.
- Cloned repos under `_inspired/` retain their original licenses. The `install-inspired.sh` script never modifies or re-licenses them — symlinks only.
- No code was copy-pasted verbatim without attribution; patterns and concepts were reimplemented to fit this bundle's deterministic/no-deps constraints.

## How to extend

Add a new inspiration:

1. Add a row to the table above with source, license, and what pattern you're adopting.
2. If you want the repo cloned, add it to `scripts/install-inspired.sh`.
3. If you want a command, add `user/commands/<name>.md` and list it in `docs/COMMANDS.md`.
4. Bump `docs/CHANGELOG.md`.
