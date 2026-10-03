#!/usr/bin/env pwsh
# install-warp.ps1 — Install Warp terminal + migrate Alacritty theme.
# Linux: calls the bash twin (apt-based, needs sudo).
# Windows: downloads MSI from warp.dev.
# macOS: points at .dmg.
#
# The theme migration (Alacritty → Warp YAML) is shared logic in Python.

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0

function Migrate-AlacrittyTheme {
    $alacPath = Join-Path $HOME '.config/alacritty/alacritty.toml'
    if (-not (Test-Path $alacPath)) {
        Write-Host '⚠ no Alacritty config — skipping theme migration'
        return
    }
    $py = if (Get-Command python3 -ErrorAction SilentlyContinue) { 'python3' } else { 'python' }
    if (-not (Get-Command $py -ErrorAction SilentlyContinue)) {
        Write-Host '⚠ python not found — cannot migrate theme automatically'
        return
    }
    & $py -c "
import tomllib, json, os
from pathlib import Path

alac = Path.home() / '.config/alacritty/alacritty.toml'
cfg = tomllib.load(open(alac, 'rb'))

def hx(s): return '#' + str(s)[2:] if str(s or '').startswith('0x') else s

colors = cfg.get('colors', {})
theme = {
    'name': 'universal-agentic-setup',
    'accent': hx(colors.get('normal',{}).get('green','0x88C999')),
    'background': hx(colors.get('primary',{}).get('background','0x0a1f0a')),
    'foreground': hx(colors.get('primary',{}).get('foreground','0xe0e0e0')),
    'details': 'darker',
    'terminal_colors': {
        'normal': {k: hx(v) for k,v in colors.get('normal',{}).items() if k in ('black','red','green','yellow','blue','magenta','cyan','white')},
        'bright': {k: hx(v) for k,v in colors.get('bright',{}).items() if k in ('black','red','green','yellow','blue','magenta','cyan','white')},
    },
}

def to_yaml(d, ind=0):
    out = []
    pad = '  '*ind
    for k,v in d.items():
        if isinstance(v, dict):
            out.append(f'{pad}{k}:'); out.append(to_yaml(v, ind+1))
        elif v is None: continue
        else: out.append(f'{pad}{k}: \"{v}\"')
    return '\n'.join(out)

out_dir = Path.home() / '.warp/themes'
out_dir.mkdir(parents=True, exist_ok=True)
(out_dir/'universal-agentic-setup.yaml').write_text(to_yaml(theme)+'\n')
print(f'wrote {out_dir/\"universal-agentic-setup.yaml\"}')
"
}

if (Get-Command warp-terminal -ErrorAction SilentlyContinue -or $IsWindows -and (Get-Command 'warp' -ErrorAction SilentlyContinue)) {
    Write-Host "✓ Warp already installed"
    Migrate-AlacrittyTheme
    exit 0
}

if ($IsWindows) {
    $msi = Join-Path ([IO.Path]::GetTempPath()) 'WarpSetup.msi'
    Write-Host "▸ Downloading Warp for Windows"
    Invoke-WebRequest -Uri 'https://app.warp.dev/download?package=msi' -OutFile $msi -UseBasicParsing
    Start-Process -FilePath msiexec.exe -ArgumentList "/i `"$msi`"" -Wait
    Migrate-AlacrittyTheme
}
elseif ($IsMacOS) {
    Write-Host '▸ macOS: brew install --cask warp    (or download from https://app.warp.dev)'
}
else {
    # Linux — delegate to the bash twin (uses apt + sudo)
    $bashInstaller = Join-Path $PSScriptRoot 'install-warp.sh'
    if (Test-Path $bashInstaller) {
        Write-Host "▸ Delegating to bash twin for Linux apt install"
        & bash $bashInstaller
    } else {
        Write-Host "⚠ bash twin not found at $bashInstaller"
    }
}
