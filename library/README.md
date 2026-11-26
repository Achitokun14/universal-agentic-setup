# Universal skill library

70 portable agent skills (`SKILL.md` folders), tool manifests for Windows, macOS and Linux, per-agent install notes and dry-run-first installers. Works with any agent that reads Agent Skills style folders: Claude Code, OpenCode, Codex CLI, Gemini CLI, Antigravity, Cursor, Hermes, omp and others.

> **Nothing here installs anything by itself.** `install.sh` / `install.ps1` only PRINT what they would do unless you pass `--apply` / `-Apply`. They copy skill folders only: no network calls, no edits to agent settings, instruction files or MCP configs, and no system tools are installed (`--install-tools` only prints the manifest command to run yourself).

## Layout

```
library/
  skills/<name>/SKILL.md      70 skills (+ references/, scripts/, SOURCES.md where derived from upstream)
  skills/index.json           name, description, dependencies, upstream licences per skill
  catalog/                    third-party skills that are listed but NOT bundled (source + install command)
  tools/manifest.json         CLI tools the skills use, with winget / scoop / apt / dnf / brew names
  tools/os/                   windows-winget.json, windows-winget-optional.json, windows-scoop.json,
                              debian-apt.txt, fedora-dnf.txt, Brewfile, npm-global.txt, pipx.txt
  tools/agents/               one JSON per agent (skill folder, instruction file, MCP config, how to install it)
  tools/security/             scan_static.py, inject_test.py, scrub_check.py (reproduce the security tests)
  docs/                       MERGES.md (what was merged / not bundled), ROUNDS.md (provenance), SECURITY.md (results)
  NOTICE.md                   attributions and licence caveats
  install.sh  install.ps1     dry-run-first installers
```

## Skill format

Every skill is a folder with `SKILL.md`:

- YAML frontmatter with only `name` (= folder name) and `description` (one line, at most 200 characters, says what the skill does and when to use it).
- Body in plain instructions that any agent can follow; long material in `references/*.md`; scripts exist as a cross-platform Python/Node script or as both `.sh` and `.ps1`.
- OS-specific commands sit in labelled `macOS / Linux (bash)` and `Windows (PowerShell)` blocks.
- No machine-specific paths, hostnames, accounts or secrets. Paid, networked, destructive or publishing steps are written as "ask the user first".

## Quick start (dry run first)

```bash
# macOS / Linux
./install.sh --list-agents
./install.sh --agents shared,claude,opencode            # prints the plan
./install.sh --agents shared,claude,opencode --apply    # copies the folders
./install.sh --skills stageshow,docker --agents claude --mode link --apply
```

```powershell
# Windows (PowerShell 5.1 or 7)
.\install.ps1 -ListAgents
.\install.ps1 -Agents shared,claude,opencode            # prints the plan
.\install.ps1 -Agents shared,claude,opencode -Apply     # copies the folders
```

Existing skill folders are skipped. `--update` / `-Update` first moves the old folder to `<skills-dir>-backups/YYYYMMDD/<name>` (a sibling folder that agents do not scan) before replacing it. `shared` is `~/.agents/skills`, which several agents read (see `tools/agents/*.json` for the vendor-cited paths); install to `shared` OR to individual agents, not both, to avoid duplicates.

## Tools

`tools/manifest.json` lists each optional CLI with the skills that use it. winget ids were checked with `winget show` (read-only); scoop/apt/dnf/brew names are unverified: check before use. Examples (run them yourself):

```
winget import -i tools\os\windows-winget.json --accept-source-agreements
brew bundle --file=tools/os/Brewfile
xargs -a tools/os/debian-apt.txt sudo apt-get install -y
```

## Security

Every skill went through static rules, SkillSpector (static mode) and a prompt-injection test: see `docs/SECURITY.md`. Reproduce with `tools/security/` (`python scan_static.py ../../skills`, `python inject_test.py ../../skills --agent ollama --model <name>`). Treat any skill, local or downloaded, as untrusted text: read it before installing, and keep approval prompts on.

## Licence

The licence for this folder is **not chosen yet** - see `LICENSE-CHOICE.md`. Bundled material keeps its upstream licences (`NOTICE.md`).
