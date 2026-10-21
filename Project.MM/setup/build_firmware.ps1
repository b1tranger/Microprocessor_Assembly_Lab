<#
.SYNOPSIS
    Builds the ESP32 NAS Firmware using PlatformIO CLI.
.DESCRIPTION
    Runs compilation inside LocalConfig/ and verifies output binaries.
#>

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$projectDir = Join-Path (Split-Path -Parent $scriptDir) "LocalConfig"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Building ESP32 NAS Firmware with PlatformIO " -ForegroundColor Cyan
Write-Host " Target Directory: $projectDir" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

Push-Location $projectDir
try {
    python -m platformio run
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
