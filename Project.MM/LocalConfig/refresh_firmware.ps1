<#
.SYNOPSIS
    Manually refreshes and compiles the ESP32 NAS Firmware.
.DESCRIPTION
    1. Re-generates include/default_assets.h from data/www/ and data/default/.
    2. Mirrors data/www/ into data/network/www/ for Wokwi's virtual SD card.
    3. Runs PlatformIO build (python -m platformio run or pio run).
    4. Reports generated binary (.pio/build/esp32dev/firmware.bin) with exact byte size.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUNBUFFERED = "1"

$projectDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Refreshing ESP32 NAS Firmware Build " -ForegroundColor Cyan
Write-Host " Project Directory: $projectDir" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

Push-Location $projectDir
try {
    # 1. Sync embedded C++ assets from data/
    $genScriptPs = Join-Path $projectDir "scripts\generate_assets.ps1"
    if (Test-Path $genScriptPs) {
        Write-Host "`n[1/3] Syncing embedded assets from data/ folder..." -ForegroundColor Cyan
        & powershell -ExecutionPolicy Bypass -File $genScriptPs
    }

    # 2. Mirror data/www/ to data/network/www/ for Wokwi SD card writeback
    $wwwSource = Join-Path $projectDir "data\www"
    $networkWww = Join-Path $projectDir "data\network\www"
    if (Test-Path $wwwSource) {
        Write-Host "`n[2/3] Mirroring data/www/ to data/network/www/..." -ForegroundColor Cyan
        if (-not (Test-Path $networkWww)) {
            New-Item -ItemType Directory -Path $networkWww -Force | Out-Null
        }
        Copy-Item -Path "$wwwSource\*" -Destination $networkWww -Force -Recurse
        Write-Host "      Synchronized www files to virtual SD disk." -ForegroundColor Green
    }

    # 3. Compile firmware with PlatformIO
    Write-Host "`n[3/3] Compiling firmware via PlatformIO..." -ForegroundColor Cyan
    $pioCmd = $null
    if (Get-Command "pio" -ErrorAction SilentlyContinue) {
        $pioCmd = "pio"
    } elseif (Get-Command "platformio" -ErrorAction SilentlyContinue) {
        $pioCmd = "platformio"
    }

    if ($pioCmd) {
        & $pioCmd run
    } else {
        python -u -m platformio run
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n[RETRY] Build encountered a lock or error. Retrying build in 2s..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        if ($pioCmd) { & $pioCmd run } else { python -u -m platformio run }
    }

    $binPath = Join-Path $projectDir ".pio\build\esp32dev\firmware.bin"
    if ($LASTEXITCODE -eq 0 -and (Test-Path $binPath)) {
        $binSize = (Get-Item $binPath).Length
        Write-Host "`n==================================================" -ForegroundColor Green
        Write-Host " [SUCCESS] Firmware build refreshed successfully! " -ForegroundColor Green
        Write-Host " Binary: $binPath" -ForegroundColor Green
        Write-Host " Size  : $binSize bytes" -ForegroundColor Green
        Write-Host "==================================================" -ForegroundColor Green
        Write-Host "`n[TIP] In VS Code with diagram.json open:" -ForegroundColor Yellow
        Write-Host "      Click Stop (red square) -> Start (play button) to boot the new firmware." -ForegroundColor White
    } else {
        Write-Host "`n[ERROR] Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} finally {
    Pop-Location
}

