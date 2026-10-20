<#
.SYNOPSIS
    Starts the Wokwi IoT Gateway with local port forwarding.
.DESCRIPTION
    Bridges localhost:9080 to the simulated ESP32 node at 10.13.37.2:80.
#>

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$gwPath = Join-Path $scriptDir "wokwigw.exe"

if (-not (Test-Path $gwPath)) {
    # Check parent project folder
    $gwPath = Join-Path (Split-Path -Parent $scriptDir) "LocalConfig\wokwigw.exe"
}

if (-not (Test-Path $gwPath)) {
    Write-Host "[ERROR] wokwigw.exe not found! Run install_dependencies.ps1 first." -ForegroundColor Red
    exit 1
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Starting Wokwi IoT Gateway (wokwigw) " -ForegroundColor Cyan
Write-Host " Forwarding: localhost:9080 -> 10.13.37.2:80 " -ForegroundColor Yellow
Write-Host " WebSocket : ws://localhost:9011 (for Wokwi extension)" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Keep this terminal window OPEN while simulating!`n" -ForegroundColor Green

& $gwPath --forward 9080:10.13.37.2:80
