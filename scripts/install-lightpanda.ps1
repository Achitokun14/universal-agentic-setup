#!/usr/bin/env pwsh
# Downloads Lightpanda (AI-first headless browser) and registers it as a Claude MCP.
# 16x less memory, 9x faster than headless Chrome for scraping/automation.

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0

$BinDir = Join-Path $HOME '.local/bin'
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

# Detect arch/os → asset suffix
$os   = if ($IsWindows) { 'windows' } elseif ($IsMacOS) { 'macos' } else { 'linux' }
$arch = switch -Regex ([System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture) {
    'X64'   { 'x86_64' ; break }
    'Arm64' { 'aarch64'; break }
    default { $null }
}
if (-not $arch) {
    [Console]::Error.WriteLine("unsupported arch: $([System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture)")
    exit 2
}
# Lightpanda asset naming: "<arch>-<os>" (e.g. x86_64-linux), not "<os>-<arch>".
$assetSuffix = "$arch-$os"

Write-Host '▸ Fetching latest Lightpanda release...'
try {
    $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/lightpanda-io/browser/releases/latest' -Headers @{ 'User-Agent' = 'universal-agentic-setup' }
}
catch {
    [Console]::Error.WriteLine("GitHub API failed: $_")
    exit 3
}

$asset = $release.assets | Where-Object { $_.name -like "*$assetSuffix*" } | Select-Object -First 1
if (-not $asset) {
    Write-Host "Could not find a release asset for $assetSuffix."
    Write-Host 'Visit https://github.com/lightpanda-io/browser/releases and download manually.'
    exit 3
}

Write-Host "▸ Downloading: $($asset.browser_download_url)"
$tmp = Join-Path ([IO.Path]::GetTempPath()) ("lightpanda-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
try {
    $dl = Join-Path $tmp 'lightpanda.bin'
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $dl -UseBasicParsing

    $binName = if ($IsWindows) { 'lightpanda.exe' } else { 'lightpanda' }
    $installed = Join-Path $BinDir $binName

    switch -Regex ($asset.name) {
        '\.tar\.gz$|\.tgz$' {
            $extract = Join-Path $tmp 'extract'
            New-Item -ItemType Directory -Force -Path $extract | Out-Null
            tar -xzf $dl -C $extract
            $bin = Get-ChildItem -Recurse -File $extract | Where-Object Name -Match 'lightpanda' | Select-Object -First 1
            if (-not $bin) { throw "no lightpanda binary found in archive" }
            Copy-Item -Force $bin.FullName $installed
            break
        }
        '\.zip$' {
            $extract = Join-Path $tmp 'extract'
            Expand-Archive -Path $dl -DestinationPath $extract -Force
            $bin = Get-ChildItem -Recurse -File $extract | Where-Object Name -Match 'lightpanda' | Select-Object -First 1
            if (-not $bin) { throw "no lightpanda binary found in archive" }
            Copy-Item -Force $bin.FullName $installed
            break
        }
        default {
            Copy-Item -Force $dl $installed
        }
    }

    if (-not $IsWindows) { & chmod +x $installed 2>$null }

    Write-Host "✓ Installed: $installed"
    & $installed --version 2>&1 | Select-Object -First 3
}
finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}

# Register as Claude MCP
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "▸ Registering as MCP 'lightpanda'..."
    try {
        # Use the real subcommand "mcp" (not "serve --mcp"; that syntax was from earlier builds).
        claude mcp add lightpanda -- $installed mcp 2>&1 | Select-Object -Last 3
    }
    catch {
        Write-Host "⚠ Could not auto-register. Run manually: claude mcp add lightpanda -- $installed mcp"
    }
}
else {
    Write-Host '⚠ claude CLI not in PATH — skipping MCP registration'
}

Write-Host ''
Write-Host 'Done. Open a new Claude Code session to pick up the MCP.'
