<!-- Derived from core/tools/catalog.json — edit the catalog, not this list. -->
# CLI tools catalog

Companion CLIs that make every coding agent more effective. Counts computed from
[`core/tools/catalog.json`](../core/tools/catalog.json): **8 core · 7 optional**.
The repo does **not** auto-install these — `core/tools/catalog.json` is data for
your own bootstrap (per-OS install commands live there).

## Tier: core (8)

| Tool | Why | Windows | macOS | Debian |
|---|---|---|---|---|
| ripgrep | Fast gitignore-aware search used by most agents. | `winget install BurntSushi.ripgrep.MSVC` | `brew install ripgrep` | `apt-get install -y ripgrep` |
| fd | Fast find replacement. | `winget install sharkdp.fd` | `brew install fd` | `apt-get install -y fd-find` |
| uv | Python/tool manager; prerequisite for many agent tools. | `winget install astral-sh.uv` | `brew install uv` | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| fzf | Fuzzy picker for history, files, hosts. | `winget install junegunn.fzf` | `brew install fzf` | `apt-get install -y fzf` |
| zoxide | Frecency-based cd. | `winget install ajeetdsouza.zoxide` | `brew install zoxide` | `apt-get install -y zoxide` |
| lazygit | Git TUI for reviewing agent commits. | `winget install JesseDuffield.lazygit` | `brew install lazygit` | see lazygit repo |
| just | One canonical command runner per repo for agents. | `winget install Casey.Just` | `brew install just` | `apt-get install -y just` |
| ast-grep | Structural search/rewrite. | `npm i -g @ast-grep/cli` | `brew install ast-grep` | `npm i -g @ast-grep/cli` |

Note: zoxide (and similar) need a shell-init line in your profile — e.g. PowerShell:
`Invoke-Expression (& { (zoxide init powershell | Out-String) })`.

## Tier: optional (7)

| Tool | Why | Install | Caution |
|---|---|---|---|
| difftastic | Syntax-aware diffs. | `winget install Wilfred.difftastic` / `brew install difftastic` / `cargo install difftastic` | — |
| ccusage | Token/cost reports for 18 agent CLIs from local logs (no omp source yet). | `npx ccusage@latest` | — |
| repomix | Pack a repo into one token-counted file with secret exclusion. | `npx repomix@latest` | — |
| rtk | Compresses shell tool output 60-90% before it reaches the model. | `winget install rtk-ai.rtk` / `brew install rtk` | `rtk init -g --agent <agent>` writes hooks into the agent's config; lossy by design (use `rtk proxy` to bypass). |
| cass | Cross-agent session search index (omp connector, SSH multi-machine sync). | scoop (see catalog) | Indexes full transcripts (may include secrets); keep the index local; alpha software. |
| ccmanager | Windows-friendly manager for parallel Claude/Codex/Gemini/OpenCode sessions (no tmux). | `npm install -g ccmanager` | — |
| beads (bd) | Dependency-aware task tracker shared by agents across machines (Dolt sync). | `npm i -g @beads/bd` | Pre-1.0, schema churn. |
