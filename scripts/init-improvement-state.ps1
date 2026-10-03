#!/usr/bin/env pwsh
# Creates IMPROVEMENT_STATE.json in any project folder that has CLAUDE.md but lacks the state file.
# Tracks iterations, changes, metrics per session.

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0

$SearchRoots = @((Join-Path $HOME 'Desktop'))
$SkipFragments = @(
    [IO.Path]::DirectorySeparatorChar + 'node_modules' + [IO.Path]::DirectorySeparatorChar
    [IO.Path]::DirectorySeparatorChar + '.cache' + [IO.Path]::DirectorySeparatorChar
    [IO.Path]::DirectorySeparatorChar + '.claude' + [IO.Path]::DirectorySeparatorChar + 'plugins' + [IO.Path]::DirectorySeparatorChar
    [IO.Path]::DirectorySeparatorChar + 'universal-agentic-setup' + [IO.Path]::DirectorySeparatorChar
)

function Should-Skip([string]$Path) {
    foreach ($frag in $SkipFragments) {
        if ($Path.Contains($frag)) { return $true }
    }
    return $false
}

$created = 0
$skipped = 0

foreach ($root in $SearchRoots) {
    if (-not (Test-Path $root)) { continue }
    $found = Get-ChildItem -Path $root -Recurse -Depth 5 -File -Filter 'CLAUDE.md' -ErrorAction SilentlyContinue
    foreach ($f in $found) {
        $projectDir = $f.Directory.FullName
        if (Should-Skip $projectDir) { continue }

        $statePath = Join-Path $projectDir 'IMPROVEMENT_STATE.json'
        if (Test-Path $statePath) { $skipped++; continue }

        $now = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        $state = [ordered]@{
            '$schema'          = 'https://github.com/Achitokun14/universal-agentic-setup/improvement-state.schema.json'
            project            = $f.Directory.Name
            path               = $projectDir
            created_at         = $now
            current_iteration  = 0
            last_updated       = $now
            iterations         = @()
            metrics            = [ordered]@{
                total_files_touched = 0
                total_lines_added   = 0
                total_lines_removed = 0
                total_commits       = 0
                iterations_count    = 0
            }
            pending_todos          = @()
            completed_todos        = @()
            learnings              = @()
            dependencies_added     = @()
            resources_discovered   = @()
        }

        ($state | ConvertTo-Json -Depth 10) | Set-Content -Path $statePath -Encoding UTF8
        Write-Host "✓ created: $statePath"
        $created++
    }
}

Write-Host ''
Write-Host "Summary: $created created · $skipped already existed"
