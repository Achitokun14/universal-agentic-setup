#!/usr/bin/env pwsh
# universal-agentic-setup — Claude-canonical installer — MERGE mode (PowerShell twin of install.sh).
# Never overwrites existing configs: deep-merges JSON, appends managed blocks to markdown.
#
# Usage:
#   ./install.ps1 [-DryRun] -Mode user
#   ./install.ps1 [-DryRun] -Mode project -Target /absolute/path/to/repo

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('user','project')]
    [string]$Mode,

    [Parameter(Position = 1)]
    [string]$Target,

    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0

$BundleDir = Split-Path -Parent $PSCommandPath

function Say([string]$m)  { Write-Host "▸ $m" }
function Warn([string]$m) { Write-Host "⚠ $m" -ForegroundColor Yellow }

function Invoke-Step([scriptblock]$Block, [string]$Label) {
    if ($DryRun) { Write-Host "   (dry-run) $Label"; return }
    & $Block
}

function Backup-IfExists([string]$Path) {
    if ((Test-Path $Path) -and -not (Get-Item $Path).PSIsContainer -and -not (Get-Item $Path).LinkType) {
        $bak = "$Path.bak." + (Get-Date -Format 'yyyyMMdd_HHmmss')
        Say "backup: $Path → $bak"
        Invoke-Step { Copy-Item -LiteralPath $Path -Destination $bak } "cp $Path $bak"
    }
}

# ---- JSON deep-merge ----
function Merge-Lists($a, $b) {
    # Concatenate and dedupe by JSON-string key (stable order)
    $seen = [System.Collections.Generic.HashSet[string]]::new()
    $out = [System.Collections.ArrayList]::new()
    foreach ($item in @($a) + @($b)) {
        $k = ($item | ConvertTo-Json -Depth 20 -Compress)
        if ($seen.Add($k)) { [void]$out.Add($item) }
    }
    return ,@($out.ToArray())
}

function Merge-Hashtables($a, $b) {
    # Deep-merge $b into $a. Lists → concat+dedupe. Dicts → merge keys. Scalars → keep $a unless falsy.
    if ($a -is [System.Collections.IDictionary] -and $b -is [System.Collections.IDictionary]) {
        $out = [ordered]@{}
        foreach ($k in $a.Keys) { $out[$k] = $a[$k] }
        foreach ($k in $b.Keys) {
            if ($out.Contains($k)) { $out[$k] = Merge-Hashtables $out[$k] $b[$k] }
            else                   { $out[$k] = $b[$k] }
        }
        return $out
    }
    if ($a -is [System.Collections.IList] -and $b -is [System.Collections.IList]) {
        return Merge-Lists $a $b
    }
    # Scalar conflict: prefer existing unless it's actually null or empty.
    # CRITICAL: do NOT use loose -eq '' — that coerces $false to empty and flips it to $b.
    if ($null -eq $a) { return $b }
    if ($a -is [string] -and $a.Length -eq 0) { return $b }
    if ($a -is [System.Collections.IList] -and $a.Count -eq 0) { return $b }
    return $a
}

function Normalize-Hooks($hooksSection) {
    # Collapse duplicate hook entries by (event, matcher).
    if (-not ($hooksSection -is [System.Collections.IDictionary])) { return $hooksSection }
    $out = [ordered]@{}
    foreach ($event in $hooksSection.Keys) {
        $entries = $hooksSection[$event]
        if (-not ($entries -is [System.Collections.IList])) { $out[$event] = $entries; continue }

        $byMatcher = [ordered]@{}
        foreach ($entry in $entries) {
            if (-not ($entry -is [System.Collections.IDictionary])) { continue }
            $m = if ($entry.Contains('matcher')) { [string]$entry['matcher'] } else { '' }
            if (-not $byMatcher.Contains($m)) {
                $slot = [ordered]@{}
                if ($m) { $slot['matcher'] = $m }
                $slot['hooks'] = [System.Collections.ArrayList]::new()
                $byMatcher[$m] = $slot
            }
            $slot = $byMatcher[$m]
            $existingKeys = [System.Collections.Generic.HashSet[string]]::new()
            foreach ($h in $slot['hooks']) { [void]$existingKeys.Add(($h | ConvertTo-Json -Depth 20 -Compress)) }

            $incoming = if ($entry.Contains('hooks')) { $entry['hooks'] } else { @() }
            foreach ($h in $incoming) {
                $k = ($h | ConvertTo-Json -Depth 20 -Compress)
                if ($existingKeys.Add($k)) { [void]$slot['hooks'].Add($h) }
            }
        }
        # Normalize inner ArrayLists back to plain arrays
        $list = [System.Collections.ArrayList]::new()
        foreach ($slot in $byMatcher.Values) {
            $slot['hooks'] = @($slot['hooks'].ToArray())
            [void]$list.Add($slot)
        }
        $out[$event] = @($list.ToArray())
    }
    return $out
}

function Merge-Json([string]$ExistingPath, [string]$BundlePath) {
    $existing = @{}
    if ($ExistingPath -and (Test-Path $ExistingPath) -and (Get-Item $ExistingPath).Length -gt 0) {
        try {
            $existing = Get-Content -Raw $ExistingPath | ConvertFrom-Json -AsHashtable -Depth 40
        }
        catch {
            Warn "JSON decode error in $ExistingPath : $_"
            throw
        }
    }
    $bundle = Get-Content -Raw $BundlePath | ConvertFrom-Json -AsHashtable -Depth 40

    $merged = Merge-Hashtables $existing $bundle
    if ($merged -is [System.Collections.IDictionary] -and $merged.Contains('hooks')) {
        $merged['hooks'] = Normalize-Hooks $merged['hooks']
    }
    return ($merged | ConvertTo-Json -Depth 40)
}

# ---- Managed-block append/replace for markdown ----
function Install-ManagedMd([string]$TargetPath, [string]$BundlePath) {
    # PREFIX-only check: actual markers in the bundle templates include a trailing
    # comment ("(do not edit between these markers — rerun installer to update)").
    $beginPrefix = '<!-- BEGIN: universal-agentic-setup managed block'
    $bundleText  = (Get-Content -Raw $BundlePath).Trim()

    if ((Test-Path $TargetPath) -and (Select-String -Path $TargetPath -SimpleMatch -Pattern $beginPrefix -Quiet)) {
        Say "markdown: replacing managed block(s) in $TargetPath"
        $existing = Get-Content -Raw $TargetPath
        # Block-with-surrounding-blank-lines regex; collapses ALL occurrences.
        $pattern = [regex]::new(
            '\n*<!-- BEGIN: universal-agentic-setup managed block.*?<!-- END: universal-agentic-setup managed block -->\n*',
            'Singleline'
        )
        $cleaned = $pattern.Replace($existing, '').TrimEnd()
        $prefix = if ($cleaned) { $cleaned + "`n`n" } else { '' }
        $new    = $prefix + $bundleText + "`n"
        Invoke-Step { Set-Content -LiteralPath $TargetPath -Value $new -Encoding UTF8 -NoNewline } "replace managed block in $TargetPath"
    }
    elseif (Test-Path $TargetPath) {
        Say "markdown: appending managed block to $TargetPath"
        Invoke-Step {
            Add-Content -LiteralPath $TargetPath -Value "`n`n" -NoNewline
            Add-Content -LiteralPath $TargetPath -Value $bundleText
        } "append managed block to $TargetPath"
    }
    else {
        Say "markdown: creating $TargetPath from bundle"
        Invoke-Step { Copy-Item -LiteralPath $BundlePath -Destination $TargetPath } "cp $BundlePath $TargetPath"
    }
}

# ---- .gitignore merge ----
function Merge-Gitignore([string]$TargetPath, [string]$BundlePath) {
    $existing = if (Test-Path $TargetPath) { Get-Content -LiteralPath $TargetPath } else { @() }
    $added = $false
    $toAdd = @()
    foreach ($line in Get-Content -LiteralPath $BundlePath) {
        if (-not $line -or $line.StartsWith('#')) { continue }
        if ($existing -notcontains $line) {
            if (-not $added) { $toAdd += ''; $toAdd += '# universal-agentic-setup'; $added = $true }
            $toAdd += $line
        }
    }
    if ($added) {
        Invoke-Step { Add-Content -LiteralPath $TargetPath -Value ($toAdd -join "`n") } "append gitignore lines"
        Say 'gitignore: appended missing entries'
    }
}

# ---- Dependency check ----
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Warn 'git not installed — symlinks to _inspired repos will fail later' }

# ======================================================
# USER SCOPE
# ======================================================
if ($Mode -eq 'user') {
    $ClaudeDir = Join-Path $HOME '.claude'
    Say "User scope → $ClaudeDir/"
    Invoke-Step {
        New-Item -ItemType Directory -Force -Path $ClaudeDir,(Join-Path $ClaudeDir 'hooks'),(Join-Path $ClaudeDir 'docs') | Out-Null
    } "mkdir -p $ClaudeDir/{,hooks,docs}"

    # settings.json
    $settingsTarget = Join-Path $ClaudeDir 'settings.json'
    Backup-IfExists $settingsTarget
    $merged = Merge-Json $settingsTarget (Join-Path $BundleDir 'user/settings.json')
    if ($DryRun) {
        Say 'settings.json: would merge (preview first 30 lines):'
        ($merged -split "`n" | Select-Object -First 30) | ForEach-Object { Write-Host "     $_" }
    }
    else {
        Set-Content -LiteralPath $settingsTarget -Value $merged -Encoding UTF8
        Say "settings.json: merged → $settingsTarget"
    }

    # CLAUDE.md & AGENTS.md managed blocks
    Install-ManagedMd (Join-Path $ClaudeDir 'CLAUDE.md') (Join-Path $BundleDir 'user/CLAUDE.md')
    Install-ManagedMd (Join-Path $ClaudeDir 'AGENTS.md') (Join-Path $BundleDir 'core/AGENTS.md')

    # Hooks — add only if missing; skip .universal side-copy if byte-identical
    Get-ChildItem -Path (Join-Path $BundleDir 'user/hooks') -Filter '*.sh' -File -ErrorAction SilentlyContinue | ForEach-Object {
        $dst = Join-Path $ClaudeDir ("hooks/" + $_.Name)
        if (Test-Path $dst) {
            $same = $false
            try { $same = -not (Compare-Object (Get-Content -Raw $_.FullName) (Get-Content -Raw $dst)) } catch {}
            if ($same) {
                # identical — no .universal copy needed
            } else {
                $alt = ($dst -replace '\.[^.]+$','') + '.universal.sh'
                Say "hook: $($_.Name) differs — bundle version saved to $(Split-Path -Leaf $alt)"
                Invoke-Step { Copy-Item -LiteralPath $_.FullName -Destination $alt -Force; if (-not $IsWindows) { chmod +x $alt } } "cp $($_.FullName) $alt"
            }
        }
        else {
            Invoke-Step { Copy-Item -LiteralPath $_.FullName -Destination $dst; if (-not $IsWindows) { chmod +x $dst } } "cp $($_.FullName) $dst"
            Say "hook: installed $($_.Name)"
        }
    }

    # Docs — always refresh
    $docsDir = Join-Path $ClaudeDir 'docs'
    Get-ChildItem -Path (Join-Path $BundleDir 'user/docs') -Filter '*.md' -File -ErrorAction SilentlyContinue | ForEach-Object {
        Invoke-Step { Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $docsDir $_.Name) -Force } "cp docs/$($_.Name)"
    }
    Say "docs: refreshed $docsDir"

    # Commands — add only if missing
    $cmdDir = Join-Path $ClaudeDir 'commands'
    Invoke-Step { New-Item -ItemType Directory -Force -Path $cmdDir | Out-Null } "mkdir $cmdDir"
    $srcCmd = Join-Path $BundleDir 'user/commands'
    if (Test-Path $srcCmd) {
        Get-ChildItem -Path $srcCmd -Filter '*.md' -File -ErrorAction SilentlyContinue | ForEach-Object {
            $dst = Join-Path $cmdDir $_.Name
            if (Test-Path $dst) {
                $same = $false
                try { $same = -not (Compare-Object (Get-Content -Raw $_.FullName) (Get-Content -Raw $dst)) } catch {}
                if ($same) {
                    # identical — no .universal copy needed
                } else {
                    $alt = ($dst -replace '\.[^.]+$','') + '.universal.md'
                    Say "command: $($_.Name) differs — bundle version saved to $(Split-Path -Leaf $alt)"
                    Invoke-Step { Copy-Item -LiteralPath $_.FullName -Destination $alt -Force } "cp $($_.FullName) $alt"
                }
            }
            else {
                Invoke-Step { Copy-Item -LiteralPath $_.FullName -Destination $dst } "cp $($_.FullName) $dst"
                Say "command: installed $($_.Name)"
            }
        }
    }

    # v2 — agent-neutral sync (core/AGENTS.md block + core/mcp catalog for this agent)
    $py = Get-Command python -ErrorAction SilentlyContinue
    if (-not $py) { $py = Get-Command python3 -ErrorAction SilentlyContinue }
    if ($DryRun) {
        Say 'agentic_sync: would run --apply --only claude-code'
    }
    elseif ($py) {
        & $py.Source (Join-Path $BundleDir 'scripts/agentic_sync.py') --apply --only claude-code
        if ($LASTEXITCODE -ne 0) { Warn 'agentic_sync exited non-zero' }
    }
    else {
        Warn 'python not found — agent-neutral sync skipped'
    }

    Say 'done. Next: start a new Claude Code session to load merged settings.'
    Say "Review: diff against backups in $ClaudeDir/*.bak.*"
}

# ======================================================
# PROJECT SCOPE
# ======================================================
if ($Mode -eq 'project') {
    if (-not $Target)                  { [Console]::Error.WriteLine('project mode needs a -Target path'); exit 1 }
    if (-not (Test-Path $Target))      { [Console]::Error.WriteLine("$Target is not a directory"); exit 1 }
    $Target = (Resolve-Path $Target).Path
    Say "Project scope → $Target/"

    Invoke-Step {
        New-Item -ItemType Directory -Force -Path `
            (Join-Path $Target '.claude/agents'),
            (Join-Path $Target '.claude/commands'),
            (Join-Path $Target '.claude/hooks') | Out-Null
    } "mkdir project scaffolding"

    # CLAUDE.md — managed block
    Install-ManagedMd (Join-Path $Target 'CLAUDE.md') (Join-Path $BundleDir 'project/CLAUDE.md')

    # AGENTS.md — symlink to CLAUDE.md (cross-tool convention)
    $agentsPath = Join-Path $Target 'AGENTS.md'
    if (-not (Test-Path -LiteralPath $agentsPath)) {
        try {
            Invoke-Step { New-Item -ItemType SymbolicLink -Path $agentsPath -Target 'CLAUDE.md' | Out-Null } "ln -s CLAUDE.md AGENTS.md"
            Say 'AGENTS.md: symlinked to CLAUDE.md (cross-tool compatibility)'
        }
        catch {
            Invoke-Step { Copy-Item -LiteralPath (Join-Path $Target 'CLAUDE.md') -Destination $agentsPath } "cp CLAUDE.md AGENTS.md"
            Say 'AGENTS.md: copied from CLAUDE.md (symlink unavailable on this platform)'
        }
    }
    elseif ((Get-Item $agentsPath).LinkType) {
        # existing symlink is fine
    }
    else {
        Say 'AGENTS.md: exists as a regular file — leaving untouched'
    }

    # settings.json — deep merge
    $settingsTarget = Join-Path $Target '.claude/settings.json'
    Backup-IfExists $settingsTarget
    $merged = Merge-Json $settingsTarget (Join-Path $BundleDir 'project/.claude/settings.json')
    if ($DryRun) {
        Say 'project settings.json: would merge (first 20 lines):'
        ($merged -split "`n" | Select-Object -First 20) | ForEach-Object { Write-Host "     $_" }
    }
    else {
        Set-Content -LiteralPath $settingsTarget -Value $merged -Encoding UTF8
        Say 'project settings.json: merged'
    }

    # Scaffolding stubs
    $agentsGk   = Join-Path $Target '.claude/agents/.gitkeep'
    $commandsGk = Join-Path $Target '.claude/commands/.gitkeep'
    if (-not (Test-Path $agentsGk))   { Invoke-Step { Copy-Item -LiteralPath (Join-Path $BundleDir 'project/.claude/agents/.gitkeep')   -Destination $agentsGk   } "cp agents/.gitkeep" }
    if (-not (Test-Path $commandsGk)) { Invoke-Step { Copy-Item -LiteralPath (Join-Path $BundleDir 'project/.claude/commands/.gitkeep') -Destination $commandsGk } "cp commands/.gitkeep" }

    Get-ChildItem -Path (Join-Path $BundleDir 'project/.claude/hooks') -Filter '*.example' -File -ErrorAction SilentlyContinue | ForEach-Object {
        $dst = Join-Path $Target ".claude/hooks/$($_.Name)"
        if (-not (Test-Path $dst)) { Invoke-Step { Copy-Item -LiteralPath $_.FullName -Destination $dst } "cp hook example $($_.Name)" }
    }

    # .gitignore merge
    $giTarget = Join-Path $Target '.gitignore'
    $giBundle = Join-Path $BundleDir 'user/.gitignore'
    if (Test-Path $giTarget) { Merge-Gitignore $giTarget $giBundle }
    else {
        Say '.gitignore: creating from bundle template'
        Invoke-Step { Copy-Item -LiteralPath $giBundle -Destination $giTarget } "cp .gitignore"
    }

    Say "done. Open $Target/CLAUDE.md and fill the TODO markers."
}
