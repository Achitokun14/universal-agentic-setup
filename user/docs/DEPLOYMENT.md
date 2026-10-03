# Deployment

How to install, upgrade, and roll back the bundle.

## First install (user scope, global)

```bash
cd universal-agentic-setup
./install.sh --dry-run user    # preview
./install.sh user              # apply
```

Effect:
- `~/.claude/settings.json` → **merged** (your existing allow/deny/ask entries preserved, bundle ones added, deduped)
- `~/.claude/CLAUDE.md` → **managed block appended** (or replaced in place if block already present)
- `~/.claude/hooks/*.sh` → added only if missing; existing files get a `.universal.sh` sibling for diff
- `~/.claude/docs/*.md` → always refreshed (bundle-owned reference)
- `~/.claude/settings.json.bak.<timestamp>` created before any change

## Project scope (per-repo)

```bash
./install.sh --dry-run project /path/to/repo
./install.sh project /path/to/repo
```

Effect:
- `<repo>/CLAUDE.md` → managed block appended (existing content preserved)
- `<repo>/.claude/settings.json` → merged (deduped)
- `<repo>/.claude/agents/` and `.claude/commands/` scaffolded with `.gitkeep`
- `<repo>/.claude/hooks/*.example` dropped in (inactive until renamed)
- `<repo>/.gitignore` → missing Claude-ignore lines appended

## Upgrade

After editing anything under `universal-agentic-setup/`:

```bash
./install.sh user              # for global changes
./install.sh project <repo>    # per-repo
```

The merge logic is idempotent — re-running is safe. Each run creates a new timestamped backup.

## Roll back

### One file
```bash
ls -lt ~/.claude/settings.json.bak.*    # newest first
cp ~/.claude/settings.json.bak.20260418_171705 ~/.claude/settings.json
```

### Everything
```bash
# Move any .bak.* files back in place
for f in ~/.claude/*.bak.*; do
  orig="${f%.bak.*}"
  cp "$f" "$orig"
done
```

## Uninstall (clean removal)

```bash
# Remove managed block from CLAUDE.md
sed -i '/<!-- BEGIN: universal-agentic-setup managed block -->/,/<!-- END: universal-agentic-setup managed block -->/d' ~/.claude/CLAUDE.md

# Remove hooks (those we added)
rm -f ~/.claude/hooks/{block-ai-attribution,block-secret-writes,auto-format,notify-stop,session-context}.sh

# Revert settings.json to last pre-bundle backup (oldest .bak)
oldest=$(ls -t ~/.claude/settings.json.bak.* | tail -1)
cp "$oldest" ~/.claude/settings.json

# Remove docs
rm -rf ~/.claude/docs/
```

## Sync across machines

The bundle is portable. Two supported flows:

**Via git:**
```bash
cd universal-agentic-setup
git init && git add . && git commit -m "chore: bundle v1.1.0"
git remote add origin git@github.com:<you>/universal-agentic-setup.git
git push -u origin main

# On the other machine:
git clone git@github.com:<you>/universal-agentic-setup.git
./universal-agentic-setup/install.sh user
```

**Via tarball:**
```bash
tar czf universal-agentic-setup.tar.gz -C ~ universal-agentic-setup/
scp universal-agentic-setup.tar.gz other-host:~/
ssh other-host 'tar xzf universal-agentic-setup.tar.gz && cd universal-agentic-setup && ./install.sh user'
```

Secrets (API keys, OAuth tokens) live in `~/.claude/.credentials.json` and `~/.claude/settings.local.json` — **not in the bundle**, intentionally.
