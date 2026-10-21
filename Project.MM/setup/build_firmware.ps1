<#
.SYNOPSIS
    Builds the ESP32 NAS Firmware using PlatformIO CLI.
.DESCRIPTION
    Runs compilation inside LocalConfig/ and verifies output binaries.
    Shows real-time download progress for toolchains if not yet installed.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUNBUFFERED = "1"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$projectDir = Join-Path (Split-Path -Parent $scriptDir) "LocalConfig"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Building ESP32 NAS Firmware with PlatformIO " -ForegroundColor Cyan
Write-Host " Target Directory: $projectDir" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

# Check if Espressif toolchains are already cached locally
$pioPackagesDir = Join-Path $env:USERPROFILE ".platformio\packages"
$xtensaTool = Join-Path $pioPackagesDir "toolchain-xtensa-esp-elf"
$arduinoEsp32 = Join-Path $pioPackagesDir "framework-arduinoespressif32"
$toolchainsReady = (Test-Path $xtensaTool) -and (Test-Path $arduinoEsp32)

Push-Location $projectDir
try {
    if (-not $toolchainsReady) {
        Write-Host "`n[1/2] Initializing Espressif 32 toolchains and framework..." -ForegroundColor Yellow
        Write-Host "      (First-time setup: downloading ~600MB with live progress bars)`n" -ForegroundColor Gray
        python -u -m platformio pkg install -d $projectDir
        if ($LASTEXITCODE -ne 0) {
            Write-Host "`n[ERROR] Failed to install Espressif toolchain packages." -ForegroundColor Red
            exit 1
        }
        Write-Host "`n[2/2] Compiling ESP32 NAS Firmware..." -ForegroundColor Cyan
    } else {
        Write-Host "`n[INFO] Espressif toolchains verified. Compiling firmware..." -ForegroundColor Green
    }
    
    python -u -m platformio run
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n[RETRY] Build encountered a transient file lock. Retrying incremental build..." -ForegroundColor Yellow
        Start-Sleep -Milliseconds 1500
        python -u -m platformio run
    }
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n[SUCCESS] Firmware compiled successfully!" -ForegroundColor Green
        $binPath = Join-Path $projectDir ".pio\build\esp32dev\firmware.bin"
        if (Test-Path $binPath) {
            $binSize = (Get-Item $binPath).Length
            Write-Host "Generated: firmware.bin ($binSize bytes)" -ForegroundColor Green
        }
    } else {
        Write-Host "`n[ERROR] Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    }
} finally {
    Pop-Location
}
