#!/usr/bin/env pwsh
# setup.ps1 — universal-agentic-setup entrypoint for Windows PowerShell 5.1+.
# PowerShell twin of the ./setup shell wrapper: drives scripts/agentic_sync.py,
# the agent-neutral sync engine (26-agent registry, native MCP formats).
#
#   .\setup.ps1                  # detect + plan (dry-run, nothing written)
#   .\setup.ps1 -Apply           # write configs (managed block + MCP merge)
#   .\setup.ps1 -Apply -Skills   # also install core skills via npx skills
#   .\setup.ps1 -Doctor          # diagnostics only
#   .\setup.ps1 -List            # agent registry table
#   .\setup.ps1 -Uninstall       # remove managed blocks/MCP, restore backups
#
# For the full Claude-rich user-scope deployment use .\install.ps1 -Mode user.

[CmdletBinding()]
param(
    [switch]$DryRun,   # explicit no-op: dry-run is the engine default
    [switch]$Apply,
    [switch]$Skills,
    [switch]$Doctor,
    [switch]$List,
    [switch]$Markdown,
    [switch]$Uninstall,
    [string[]]$Only,
    [string[]]$Skip,
    # Sandbox home for tests ($Home itself is a read-only PowerShell variable)
    [string]$TargetHome
)

$ErrorActionPreference = 'Stop'
$BundleDir = Split-Path -Parent $PSCommandPath

$engineArgs = @()
if ($Apply)     { $engineArgs += '--apply' }
if ($Skills)    { $engineArgs += '--skills' }
if ($Doctor)    { $engineArgs += '--doctor' }
if ($List)      { $engineArgs += '--list' }
if ($Markdown)  { $engineArgs += '--markdown' }
if ($Uninstall) { $engineArgs += '--uninstall' }
if ($Only)      { $engineArgs += @('--only', ($Only -join ',')) }
if ($Skip)      { $engineArgs += @('--skip', ($Skip -join ',')) }
if ($TargetHome){ $engineArgs += @('--home', $TargetHome) }

$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) { $py = Get-Command python3 -ErrorAction SilentlyContinue }
if (-not $py) { Write-Error 'python not found on PATH (required by scripts/agentic_sync.py)' }

Write-Host "universal-agentic-setup — running agentic_sync.py $($engineArgs -join ' ')"
& $py.Source (Join-Path $BundleDir 'scripts\agentic_sync.py') @engineArgs
exit $LASTEXITCODE
