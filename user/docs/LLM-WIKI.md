# LLM-Wiki — Persistent Compounding Notes

Inspired by Karpathy's "llm-wiki" pattern: a plain-markdown notebook that your AI coding assistant can read **and** write, accumulating context across sessions.

## Location

```
~/Desktop/ACTIVITIES/llm-wiki/
├── README.md              # the wiki's own readme
├── TEMPLATE.md            # daily-file template
├── index.md               # table of contents (manually curated)
├── YYYY-MM-DD.md          # one file per day, auto-append-only
├── weekly/YYYY-WNN.md     # /retro output
├── handoffs/              # /compress output
├── research/              # /research output
├── extracts/              # /extract output
└── media/                 # /ytdl output (videos → transcripts)
```

Initialize with:
```bash
bash universal-agentic-setup/scripts/init-llm-wiki.sh
```

## Daily files

Auto-written by the `memory-compiler.sh` Stop hook at end of each session. Each day's file accumulates:

- TodoWrite completions (what was finished)
- Git diff summary (files changed, lines +/-)
- Agent spawns (what subagents were used for)
- URLs fetched
- Manual `/learn` entries

## How Claude uses it

**On session start** — doesn't auto-load. Keep the wiki out of context unless relevant.

**During a session** — invoke via these commands:

| Command | Reads | Writes |
|---------|-------|--------|
| `/learn <x>` | — | appends to today's file |
| `/wiki <topic>` | all dated files | — |
| `/retro [N]` | all dated files + IMPROVEMENT_STATE.json | weekly file |
| `/compress` | conversation context | handoff file |
| `/research <topic>` | optional | `research/<slug>.md` |
| `/extract <src>` | source | `extracts/<slug>.md` |
| `/ytdl <url>` | video | `media/<date>-<slug>.md` |

**As a fallback** — if you're stuck, grep the wiki for the topic. Past-you may have solved it.

## Tagging convention

```markdown
**Tags:** #bug #learning #pattern #insight #gotcha #workflow #tool #security #performance
**Project:** <repo name or "cross-project">
```

`/retro` looks for these tags when summarizing the week.

## What NOT to put in the wiki

- Secrets, tokens, .env contents — `block-secret-writes.sh` hook should stop this, but double-check.
- Entire file dumps — keep entries small; link back to the file path instead.
- Things that are already in `git log` or CLAUDE.md — the wiki is for what's *not* captured elsewhere.

## Related hooks & scripts

- `user/hooks/memory-compiler.sh` — populates the daily file on Stop
- `user/hooks/entity-tracker.sh` — writes to `entities.jsonl` (graphiti-lite) on WebFetch/WebSearch
- `user/hooks/track-resources.sh` — writes URLs/packages to `useful-resources.md`
- `scripts/init-llm-wiki.sh` — scaffold the directory

## Growth expectation

- **Day 1:** ~5 entries (seeded)
- **Week 1:** 30-50 entries across daily files
- **Month 1:** 100+ entries, first patterns emerge in `/retro`
- **Month 6:** compounding value; `/wiki` becomes first-stop for debugging

The `/retro` command is what turns the raw log into insight. Run it weekly.
