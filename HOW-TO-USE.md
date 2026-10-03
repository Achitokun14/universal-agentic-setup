# How to Use — Claude Universal Bundle

Scenario-based guide. For reference docs (hooks, settings schema, full rules), see `user/docs/`.

---

## 30-second setup

Every bundled script ships as a twin — `.sh` (bash) or `.ps1` (pwsh 7+). Pick the flavor for your shell; both produce byte-identical results.

```bash
cd universal-agentic-setup

# Preview what will change (no writes)
./install.sh --dry-run user

# Apply to ~/.claude/
./install.sh user

# Seed the 4 design skills (Emil, Taste, Impeccable, UI/UX Pro Max)
./install-skills.sh

# Seed IMPROVEMENT_STATE.json into every project folder
./scripts/init-improvement-state.sh

# Bootstrap the resource-tracker from past sessions
./scripts/bootstrap-resources.sh
```

```powershell
# PowerShell 7+ equivalent (Linux, macOS, Windows)
cd universal-agentic-setup

./install.ps1 -DryRun -Mode user
./install.ps1 -Mode user
./install-skills.ps1
./scripts/init-improvement-state.ps1
./scripts/bootstrap-resources.ps1
```

Restart Claude Code. You're done.

---

## Starting a new project

```bash
# Preview
./install.sh --dry-run project ~/Desktop/<new-repo>

# Apply — creates CLAUDE.md + AGENTS.md symlink + .claude/settings.json + hooks/ example
./install.sh project ~/Desktop/<new-repo>

# Re-run the improvement seeder so the new repo gets an IMPROVEMENT_STATE.json
./scripts/init-improvement-state.sh
```

Open `<new-repo>/CLAUDE.md` and fill in the `<!-- TODO -->` markers.

---

## What happens during a Claude session (automatic)

These run without you doing anything:

| Trigger | Hook | Effect |
|---------|------|--------|
| `git commit ... Co-Authored-By: Claude` | `block-ai-attribution.sh` | Blocks the commit with an explanation |
| Write to `.env` / `*.key` / `.ssh/*` | `block-secret-writes.sh` | Blocks the write |
| Edit a `.ts` / `.py` / `.rs` / `.go` file | `auto-format.sh` | Runs biome / ruff / rustfmt / gofmt |
| Any `Bash` / `WebFetch` / `WebSearch` | `track-resources.sh` | Dedup'd resource appended to `~/Desktop/ACTIVITIES/useful-resources.md` |
| Session start | `tool-inventory.sh` | Injects y/n tool inventory + git context |
| Session stop | `notify-stop.sh` + `track-improvement.sh` + `memory-compiler.sh` | Desktop notification + iteration tracked + daily llm-wiki entry appended |
| `WebFetch` / `WebSearch` | `entity-tracker.sh` | URL + title + first paragraph → `~/Desktop/ACTIVITIES/entities.jsonl` (graphiti-lite) |

---

## Using inspired slash commands (v1.5.0+)

Twelve bundled commands live in `user/commands/`. After `./install.sh user`, invoke in any session with `/<name>`.

**Quick tour:**
```
/careful                 # next destructive command requires typed confirmation
/freeze ~/Desktop/app    # lock all writes to this dir for the session
/unfreeze                # release the lock

/autoplan add search     # parallel CEO/eng/design/DX review before coding
/pair refactor auth      # Explore + Plan agents in parallel, synthesize
/compress                # write a handoff doc for your next session

/learn TIL: <insight>    # append to today's llm-wiki file
/wiki vector db          # search past llm-wiki notes
/retro 7                 # weekly retrospective across all projects

/research Zig 0.12       # parallel multi-source cited brief
/extract https://...     # structured extraction from URL/file
/ytdl https://youtu.be/… # video → transcript → wiki entry
/crit src/auth.ts        # kimi + opencode + claude review in parallel
```

Initialize the wiki on first use:
```bash
bash universal-agentic-setup/scripts/init-llm-wiki.sh
```

Optional: clone additional OSS inspirations interactively:
```bash
bash universal-agentic-setup/scripts/install-inspired.sh
```

See `user/docs/COMMANDS.md` for full command list, `user/docs/INSPIRATIONS.md` for credits, and `user/docs/LLM-WIKI.md` for the compounding-notes pattern.

---

## Day-to-day commands

```bash
# Peek at what resources the tracker has accumulated
tail -20 ~/Desktop/ACTIVITIES/useful-resources.md

# Filter for a category
grep '| github-repo |' ~/Desktop/ACTIVITIES/useful-resources.md | tail -10
grep '| npm |'         ~/Desktop/ACTIVITIES/useful-resources.md | tail -10

# See a project's iteration history
cat ~/Desktop/<repo>/IMPROVEMENT_STATE.json | jq '.iterations[-5:]'

# Count iterations across every project
find ~/Desktop -maxdepth 5 -name IMPROVEMENT_STATE.json \
  -exec jq -r '"\(.current_iteration)\t\(.project)"' {} \; | sort -rn | head -10
```

---

## Upgrading the bundle

After editing anything in `user/` or `project/`:

```bash
./install.sh user              # redeploy to ~/.claude/
./install.sh project <repo>    # redeploy to a specific repo
```

The installer is idempotent and merge-safe:
- **settings.json** — deep-merged; your existing values win on conflict
- **CLAUDE.md / AGENTS.md** — managed block replaced in place; your other content untouched
- **hooks/** — existing hooks preserved; bundle version dropped alongside as `.universal.sh`
- **docs/** — always refreshed (bundle-owned)
- **Every change triggers a backup** with `*.bak.YYYYMMDD_HHMMSS`

---

## Sync to another machine

```bash
# on this machine
cd ~/Desktop/ACTIVITIES
tar czf universal-agentic-setup.tar.gz universal-agentic-setup/
scp universal-agentic-setup.tar.gz other-host:~/

# on the other machine
tar xzf ~/universal-agentic-setup.tar.gz
cd universal-agentic-setup
./install.sh user
./install-skills.sh
```

Secrets are **never** in the bundle — you'll need to log in / paste API keys on the new machine (`claude mcp add-env ...`, `zeroclaw auth paste-token ...`).

---

## Typical scenarios

### "I want to start a brand-new Next.js app"
```bash
npx create-next-app@latest my-app
cd my-app
universal-agentic-setup/install.sh project .
universal-agentic-setup/scripts/init-improvement-state.sh
# Open CLAUDE.md, fill TODOs. Then `claude` and go.
```

### "I want to add a rule that applies everywhere (all projects)"
Edit `user/CLAUDE.md` inside the managed block → `./install.sh user`. It merges into `~/.claude/CLAUDE.md`.

### "I want a rule that applies to one project only"
Edit `<repo>/CLAUDE.md` outside the managed block (or inside `.claude/settings.json` for allow/deny/ask).

### "I want to block a new command across all projects"
Add it to `user/settings.json` under `permissions.deny` → `./install.sh user`.

### "I want to add my own hook"
```bash
# Write it
cat > ~/.claude/hooks/my-hook.sh <<'SH'
#!/usr/bin/env bash
echo "payload: $(cat)" >> /tmp/my-hook.log
SH
chmod +x ~/.claude/hooks/my-hook.sh

# Wire it in ~/.claude/settings.json under "hooks.<Event>"
```

If it's generally useful, add it to `user/hooks/` in the bundle and commit.

---

## Troubleshooting

### Hooks don't fire
- Restart Claude Code — hooks are read at session start.
- Check `jq` is installed: `which jq` (required by all hooks).
- Check executable bit: `ls -l ~/.claude/hooks/*.sh`.
- Test manually: `echo '{"tool_name":"Bash","tool_input":{"command":"test"}}' | ~/.claude/hooks/<name>.sh; echo "exit=$?"`

### "BLOCKED: commit message contains AI attribution"
Working as intended — rewrite the commit without Co-Authored-By / Generated with / 🤖. To temporarily disable: `chmod -x ~/.claude/hooks/block-ai-attribution.sh`.

### "BLOCKED: writing to a sensitive file"
Use the `.example` variant (e.g. `.env.example`). If you really need to write the real file, disable the hook for one session: `chmod -x ~/.claude/hooks/block-secret-writes.sh` (re-enable after: `chmod +x`).

### `useful-resources.md` not updating
The hook dedups against existing entries. If you're seeing resources that were already seen in past sessions, they won't re-appear. Test with a synthetic unique string:
```bash
echo '{"tool_name":"Bash","tool_input":{"command":"npm install -g @test/zzz-'$(date +%s)'"}}' \
  | ~/.claude/hooks/track-resources.sh
tail -3 ~/Desktop/ACTIVITIES/useful-resources.md
```

### `IMPROVEMENT_STATE.json` not incrementing
The `Stop` hook only fires when Claude Code stops responding to a prompt. It walks up from `$PWD` looking for `IMPROVEMENT_STATE.json` (max 5 levels). If you launched `claude` outside a project directory, it'll no-op silently.

### I want my old settings back
Every run of `install.sh` creates `*.bak.<timestamp>` files:
```bash
ls -lt ~/.claude/settings.json.bak.*
cp ~/.claude/settings.json.bak.<timestamp> ~/.claude/settings.json
```

---

## Uninstall

```bash
# 1. Remove the managed block from CLAUDE.md + AGENTS.md
for f in ~/.claude/CLAUDE.md ~/.claude/AGENTS.md; do
  [[ -f "$f" ]] && sed -i '/<!-- BEGIN: universal-agentic-setup/,/<!-- END: universal-agentic-setup/d' "$f"
done

# 2. Remove the bundle's hooks
rm -f ~/.claude/hooks/{block-ai-attribution,block-secret-writes,auto-format,notify-stop,session-context,tool-inventory,track-improvement,track-resources}.sh

# 3. Remove bundle docs
rm -rf ~/.claude/docs/

# 4. Restore settings.json from the oldest backup (pre-bundle state)
oldest=$(ls -t ~/.claude/settings.json.bak.* 2>/dev/null | tail -1)
[[ -n "$oldest" ]] && cp "$oldest" ~/.claude/settings.json

# Optional: remove IMPROVEMENT_STATE.json from all projects
find ~/Desktop -maxdepth 5 -name IMPROVEMENT_STATE.json -delete

# Optional: delete the resources tracker
# rm ~/Desktop/ACTIVITIES/useful-resources.md
```

Restart Claude Code.

---

## File map (what lives where after install)

```
~/.claude/
├── settings.json              # merged: your values + bundle additions
├── CLAUDE.md                  # your content + <!-- managed block --> with rules
├── AGENTS.md                  # same, for Codex/Cursor/OpenCode compatibility
├── hooks/
│   ├── block-ai-attribution.sh
│   ├── block-secret-writes.sh
│   ├── auto-format.sh
│   ├── notify-stop.sh
│   ├── session-context.sh
│   ├── tool-inventory.sh
│   ├── track-improvement.sh
│   └── track-resources.sh
├── docs/                      # reference docs (refreshed each install)
└── skills/                    # (only touched by install-skills.sh)
    ├── emil-design-eng/        (symlink)
    ├── taste-skill/            (symlink)
    ├── minimalist-skill/       (symlink)
    ├── soft-skill/             (symlink)
    ├── brutalist-skill/        (symlink)
    ├── redesign-skill/         (symlink)
    └── ui-ux-pro-max/          (symlink)

~/Desktop/
├── <any-project>/
│   ├── CLAUDE.md              # your content + managed block with project template
│   ├── AGENTS.md              # symlink → CLAUDE.md
│   ├── IMPROVEMENT_STATE.json # iteration tracker (auto-updated on Stop)
│   ├── .claude/
│   │   ├── settings.json      # project-scoped permissions
│   │   ├── agents/
│   │   ├── commands/
│   │   └── hooks/
│   └── .gitignore             # appended with Claude-ignore lines
└── ACTIVITIES/
    ├── useful-resources.md    # auto-maintained resource catalog
    └── universal-agentic-setup/   # (the bundle itself)
```

---

## Related docs

- [README.md](README.md) — bundle overview, structure
- [user/docs/RULES.md](user/docs/RULES.md) — canonical rule list
- [user/docs/HOOKS.md](user/docs/HOOKS.md) — hook reference
- [user/docs/SETTINGS.md](user/docs/SETTINGS.md) — settings.json schema
- [user/docs/DEPLOYMENT.md](user/docs/DEPLOYMENT.md) — install/upgrade/rollback deep-dive
- [user/docs/MCPS.md](user/docs/MCPS.md) — MCP server catalog
- [user/docs/SKILLS.md](user/docs/SKILLS.md) — skills catalog + install matrix
- [user/docs/ACPS.md](user/docs/ACPS.md) — editor integrations
- [user/docs/CHANGELOG.md](user/docs/CHANGELOG.md) — bundle version history
