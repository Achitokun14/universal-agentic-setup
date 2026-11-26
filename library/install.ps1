<#
.SYNOPSIS
  Copy (or link) the skills in .\skills into the skill folders of your coding agents.
.DESCRIPTION
  DEFAULT IS A DRY RUN: without -Apply this script only PRINTS what it would do.
  No network calls. Never edits agent settings, instruction files or MCP configs. Never installs system tools
  (-InstallTools only prints the commands for tools\os\*).
  Works in Windows PowerShell 5.1 and PowerShell 7 (Windows, macOS, Linux).
.PARAMETER Agents   comma list: shared,claude,omp,opencode,codex,gemini,antigravity,cursor,hermes,copilot,windsurf (default shared = ~/.agents/skills)
.PARAMETER Skills   comma list of skill names or "all" (dependencies from skills\index.json are added)
.PARAMETER Mode     copy (default) or link (symbolic links; Windows needs Developer Mode or an elevated shell, otherwise use copy)
.PARAMETER Update   replace an existing skill folder (the old one is MOVED to <skills-dir>-backups\YYYYMMDD\<name>, a sibling folder agents do not scan); without it existing folders are skipped
.PARAMETER Target   install into this folder instead of the agent folders (for testing)
.PARAMETER Apply    really do it
.EXAMPLE
  .\install.ps1 -Agents claude,omp            # dry run
  .\install.ps1 -Agents claude,omp -Apply     # execute
#>
[CmdletBinding()]
param(
  [string]$Agents = "shared",
  [string]$Skills = "all",
  [ValidateSet("copy","link")][string]$Mode = "copy",
  [string]$Target = "",
  [switch]$Update,
  [switch]$Apply,
  [switch]$InstallTools,
  [switch]$ListAgents,
  [switch]$ListSkills
)
$ErrorActionPreference = "Stop"
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsSrc = Join-Path $Here "skills"
$Stamp = Get-Date -Format "yyyyMMdd"
$Home_ = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }

function Get-AgentDir([string]$a) {
  switch ($a) {
    "shared"      { return (Join-Path $Home_ ".agents\skills") }
    "claude"      { return (Join-Path $Home_ ".claude\skills") }
    "omp"         { return (Join-Path $Home_ ".omp\agent\skills") }
    "opencode"    { return (Join-Path $Home_ ".config\opencode\skills") }
    "codex"       { return (Join-Path $Home_ ".codex\skills") }
    "gemini"      { return (Join-Path $Home_ ".gemini\skills") }
    "antigravity" { return (Join-Path $Home_ ".gemini\config\skills") }
    "cursor"      { return (Join-Path $Home_ ".cursor\skills") }
    "hermes"      { $h = if ($env:HERMES_HOME) { $env:HERMES_HOME } else { Join-Path $Home_ ".hermes" }; return (Join-Path $h "skills") }
    "copilot"     { return (Join-Path $Home_ ".copilot\skills") }
    "windsurf"    { return (Join-Path $Home_ ".codeium\windsurf\skills") }
    default       { throw "unknown agent: $a (see -ListAgents)" }
  }
}
$AllAgents = @("shared","claude","omp","opencode","codex","gemini","antigravity","cursor","hermes","copilot","windsurf")
$AllSkills = @(Get-ChildItem -Directory $SkillsSrc | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") } | ForEach-Object { $_.Name })

if ($ListAgents) { foreach ($a in $AllAgents) { "{0,-12} {1}" -f $a, (Get-AgentDir $a) }; return }
if ($ListSkills) { $AllSkills; return }

# resolve selection + dependencies
$sel = if ($Skills -eq "all") { @($AllSkills) } else { @($Skills -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }
$indexPath = Join-Path $SkillsSrc "index.json"
if (Test-Path $indexPath) {
  $idx = @{}
  foreach ($s in (Get-Content $indexPath -Raw -Encoding UTF8 | ConvertFrom-Json).skills) { $idx[$s.name] = $s }
  $out = New-Object System.Collections.ArrayList
  $todo = New-Object System.Collections.Queue
  foreach ($n in $sel) { $todo.Enqueue($n) }
  while ($todo.Count -gt 0) {
    $n = $todo.Dequeue()
    if ($out -contains $n) { continue }
    if (-not $idx.ContainsKey($n)) { throw "unknown skill: $n" }
    [void]$out.Add($n)
    foreach ($r in @($idx[$n].requires)) { if ($r) { $todo.Enqueue($r) } }
  }
  $sel = @($out)
}
foreach ($s in $sel) { if (-not (Test-Path (Join-Path $SkillsSrc "$s\SKILL.md"))) { throw "unknown skill: $s" } }

if ($Apply) { "== APPLY mode ==" } else { "== DRY RUN (nothing will be written; add -Apply to execute) ==" }
"skills: $($sel.Count) | mode: $Mode | update: $($Update.IsPresent)"

function Install-One([string]$label, [string]$root) {
  "-- $label -> $root"
  if (-not (Test-Path $root)) {
    if ($Apply) { New-Item -ItemType Directory -Force -Path $root | Out-Null } else { "   would create $root" }
  }
  foreach ($s in $sel) {
    $src = Join-Path $SkillsSrc $s
    $dest = Join-Path $root $s
    if (Test-Path $dest) {
      if ($Update) {
        "   ${s}: exists -> move old copy to $root-backups\$Stamp\$s, then $Mode"
        if ($Apply) {
          $bk = "$root-backups\$Stamp"
          New-Item -ItemType Directory -Force -Path $bk | Out-Null
          Move-Item -LiteralPath $dest -Destination (Join-Path $bk $s)
        } else { continue }
      } else {
        "   ${s}: exists -> skip (use -Update to replace with backup)"; continue
      }
    } else {
      "   ${s}: new -> $Mode"
    }
    if ($Apply) {
      if ($Mode -eq "link") { New-Item -ItemType SymbolicLink -Path $dest -Target $src | Out-Null }
      else { Copy-Item -Recurse -LiteralPath $src -Destination $dest }
    }
  }
}

if ($Target) { Install-One "custom" $Target }
else { foreach ($a in ($Agents -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ })) { Install-One $a (Get-AgentDir $a) } }

if ($InstallTools) {
  ""
  "== tools (manifests in tools\os\) =="
  "Windows (winget): winget import -i tools\os\windows-winget.json --accept-source-agreements"
  "Windows (scoop):  scoop import tools\os\windows-scoop.json"
  "npm/pip globals:  tools\os\npm-global.txt, tools\os\pipx.txt"
  "(-InstallTools never runs package managers for you: read the manifest and run the command yourself)"
}
""
if (-not $Apply) { "Dry run finished. Nothing was changed." } else { "Done. Start a new agent session to load the skills." }
