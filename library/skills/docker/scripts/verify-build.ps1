# Verify Dockerfile build. Run from the project root (the directory that contains the Dockerfile).
# Usage: pwsh <path-to-this-skill>/scripts/verify-build.ps1 [-Help] [IMAGE_NAME]
# PowerShell equivalent of verify-build.sh. Adapted from docker/skills docker-build-strategies (Apache-2.0). See SOURCES.md.
param(
    [switch]$Help,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Rest
)

function Show-Usage {
    Write-Output "Usage: pwsh <path-to-this-skill>/scripts/verify-build.ps1 [-Help] [IMAGE_NAME]"
    Write-Output "Run from the project root. Builds the Dockerfile, then reports image size and configured user."
}

if ($Help -and -not $Rest) {
    Show-Usage
    exit 0
}

if ($Help -or ($Rest -and $Rest.Count -gt 1)) {
    Show-Usage | Write-Error
    exit 2
}

$Image = if ($Rest -and $Rest.Count -eq 1) { $Rest[0] } else { "verify-build-test" }

Write-Output "Building image..."
docker build -t $Image .
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Output ""
Write-Output "Image size:"
docker images $Image --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Output ""
Write-Output "User:"
docker inspect $Image --format '{{.Config.User}}'
exit $LASTEXITCODE
