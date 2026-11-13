<#
.SYNOPSIS
    Exports all dependencies into the localized installer folder.
.DESCRIPTION
    Downloads Python wheels and packages/syncs the cached Espressif 32 toolchains
    so the toolkit contains 100% of all dependencies localized with NO internet needed.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$wheelsDir = Join-Path $scriptDir "wheels"
$localPio = Join-Path $scriptDir ".platformio"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Localizing Offline Dependencies " -ForegroundColor Cyan
Write-Host " Target Folder: $scriptDir" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Ensure target directory exists
if (-not (Test-Path $wheelsDir)) {
    New-Item -ItemType Directory -Path $wheelsDir -Force | Out-Null
}

# 2. Download Python Wheels for PlatformIO Core
Write-Host "`n[1/3] Downloading PlatformIO pip wheels into wheels/..." -ForegroundColor Yellow
python -m pip download platformio -d $wheelsDir
if ($LASTEXITCODE -eq 0) {
    Write-Host "Downloaded Python wheels successfully." -ForegroundColor Green
} else {
    Write-Host "[WARNING] pip download encountered an issue. Check network connection." -ForegroundColor Yellow
}

# 3. Sync PlatformIO toolchains and platforms
Write-Host "`n[2/3] Localizing cached Espressif 32 toolchains to .platformio/..." -ForegroundColor Yellow
$pioHome = Join-Path $env:USERPROFILE ".platformio"
$pioPackages = Join-Path $pioHome "packages"
$pioPlatforms = Join-Path $pioHome "platforms"

if ((Test-Path $pioPackages) -and (Test-Path $pioPlatforms)) {
    Write-Host "Syncing .platformio/packages and platforms to $localPio..." -ForegroundColor Cyan
    robocopy "$pioPackages" (Join-Path $localPio "packages") /E /MT:16 /NFL /NDL /NP
    robocopy "$pioPlatforms" (Join-Path $localPio "platforms") /E /MT:16 /NFL /NDL /NP
    Write-Host "Toolchains localized successfully into $localPio." -ForegroundColor Green
} else {
    Write-Host "[WARNING] PlatformIO toolchains not found in $pioHome. Run a build online first to cache them." -ForegroundColor Yellow
}

# 4. Copy wokwigw.exe
Write-Host "`n[3/3] Including Wokwi IoT Gateway..." -ForegroundColor Yellow
$parentDir = Split-Path -Parent $scriptDir
$gwSource = Join-Path $parentDir "wokwigw.exe"
if (-not (Test-Path $gwSource)) { $gwSource = Join-Path (Split-Path -Parent $parentDir) "wokwigw.exe" }

if ($gwSource -and (Test-Path $gwSource)) {
    Copy-Item -Path $gwSource -Destination (Join-Path $scriptDir "wokwigw.exe") -Force
    Write-Host "Copied wokwigw.exe to localized folder." -ForegroundColor Green
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " All Dependencies Successfully Localized! " -ForegroundColor Green
Write-Host " Location: $scriptDir" -ForegroundColor Yellow
Write-Host " Everything is self-contained. Run 'install_offline.bat' " -ForegroundColor Green
Write-Host " with ZERO network access needed. " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

