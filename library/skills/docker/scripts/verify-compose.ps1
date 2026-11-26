# Verify Compose configuration. Run from the project root (the directory that contains compose.yaml).
# Usage: pwsh <path-to-this-skill>/scripts/verify-compose.ps1 [-Help]
# PowerShell equivalent of verify-compose.sh. Adapted from docker/skills docker-compose-patterns (Apache-2.0). See SOURCES.md.
param(
    [switch]$Help,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Rest
)

function Show-Usage {
    Write-Output "Usage: pwsh <path-to-this-skill>/scripts/verify-compose.ps1 [-Help]"
    Write-Output "Run from the project root. Validates compose.yaml with docker compose config --quiet (no rendered configuration)."
}

if ($Help -and -not $Rest) {
    Show-Usage
    exit 0
}

if ($Help -or $Rest) {
    Show-Usage | Write-Error
    exit 2
}

docker compose config --quiet
exit $LASTEXITCODE
