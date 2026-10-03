# Slash Commands

Custom commands invoked with `/command-name`. Each is a markdown file in `commands/`.

## Where they live

- **User scope:** `~/.claude/commands/<name>.md` — global.
- **Project scope:** `<repo>/.claude/commands/<name>.md` — per-repo.
- **Plugin-provided:** auto-registered when the plugin is enabled.

## Format

```markdown
---
description: Short summary shown in the command palette.
argument-hint: "<required-arg> [optional-arg]"
---

Instructions Claude follows when the user types `/<name> <args>`.

Use $ARGUMENTS to reference the user's input.
```

## Bundled commands (from `commit-commands` plugin)

| Command | What |
|---------|------|
| `/commit` | Stage + commit with generated conventional-commit message |
| `/commit-push-pr` | Commit, push, open a PR |
| `/clean_gone` | Delete local branches marked `[gone]` |

## Bundled (from other plugins)

| Command | Source | What |
|---------|--------|------|
| `/review` | built-in | Review current branch changes |
| `/security-review` | built-in | OWASP-focused review of pending changes |
| `/init` | built-in | Generate initial CLAUDE.md for the repo |
| `/revise-claude-md` | claude-md-management | Update CLAUDE.md with session learnings |

## Bundled (universal-agentic-setup, inspired from OSS)

Twelve commands shipped with this bundle in `user/commands/`. See `docs/INSPIRATIONS.md` for credits.

| Command | Inspired by | What |
|---------|-------------|------|
| `/careful` | gstack | Warn and require explicit confirm before destructive shell commands |
| `/freeze <dir>` | gstack | Lock all writes to a single directory for the session |
| `/unfreeze` | gstack | Release the freeze set by `/freeze` |
| `/autoplan <feature>` | gstack | Parallel CEO/eng/design/DX review before coding; GO/KILL/DEFER verdict |
| `/retro [days]` | gstack | Weekly retrospective across all projects using `IMPROVEMENT_STATE.json` |
| `/learn <insight>` | everything-claude-code | Append tagged insight to today's llm-wiki file |
| `/wiki <topic>` | karpathy llm-wiki | Search past llm-wiki notes for a topic |
| `/extract <src>` | google/langextract | Structured extraction from URL or file into JSON + grounded quotes |
| `/research <topic>` | — | Parallel multi-source research (Web + context7 + duckduckgo) → cited brief |
| `/compress` | superpowers | Write a compact handoff doc of the current session |
| `/pair <question>` | superpowers | Dispatch Explore + Plan agents in parallel, synthesize |
| `/crit <target>` | — | Cross-model adversarial review (kimi + opencode + codex if installed) |
| `/ytdl <url>` | yt-dlp | Download → whisper transcribe → markdown entry in llm-wiki |

## Writing your own

Save `~/.claude/commands/scan-todos.md`:

```markdown
---
description: Scan the repo for TODO / FIXME / HACK comments and list them.
---

Use Grep to find TODO, FIXME, HACK, XXX in all source files.
Group by file, then print the count + each location.
If $ARGUMENTS is provided, filter only files matching that pattern.
```

Invoke: `/scan-todos src/` — runs with `$ARGUMENTS=src/`.

## No restart

Commands are picked up the moment the file exists. Edit and re-invoke.

## See also

- `docs/AGENTS.md` — subagents (more powerful, isolated context)
- Claude Code docs: slash commands
