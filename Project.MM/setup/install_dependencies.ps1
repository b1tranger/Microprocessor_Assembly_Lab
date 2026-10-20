<#
.SYNOPSIS
    Automated Dependency Installer for ESP32 NAS & Web Server Simulation.
.DESCRIPTION
    Verifies Python, installs/updates PlatformIO CLI, and ensures toolchains are ready.
#>

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " ESP32 NAS Project - Dependency Verification " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Check Python
Write-Host "`n[1/3] Checking Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "Found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Python is not installed or not in PATH!" -ForegroundColor Red
    Write-Host "Please install Python 3.10+ from https://www.python.org/" -ForegroundColor Red
    exit 1
}

# 2. Install / Upgrade PlatformIO Core
Write-Host "`n[2/3] Installing / Upgrading PlatformIO CLI..." -ForegroundColor Yellow
python -m pip install -U platformio
if ($LASTEXITCODE -eq 0) {
    Write-Host "PlatformIO CLI is installed and ready." -ForegroundColor Green
} else {
    Write-Host "[ERROR] Failed to install PlatformIO via pip." -ForegroundColor Red
    exit 1
}

# 3. Check wokwigw.exe
Write-Host "`n[3/3] Verifying Wokwi IoT Gateway (wokwigw.exe)..." -ForegroundColor Yellow
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$gwPath = Join-Path $scriptDir "wokwigw.exe"
$projectGwPath = Join-Path (Split-Path -Parent $scriptDir) "LocalConfig\wokwigw.exe"

if (Test-Path $gwPath) {
    Write-Host "wokwigw.exe is present in setup/ folder." -ForegroundColor Green
    if (-not (Test-Path $projectGwPath)) {
        Write-Host "Copying wokwigw.exe to LocalConfig/..." -ForegroundColor Cyan
        Copy-Item -Path $gwPath -Destination $projectGwPath -Force
    }
} else {
    Write-Host "[WARNING] wokwigw.exe not found in setup/. Downloading latest release..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://github.com/wokwi/wokwigw/releases/latest/download/wokwigw.exe" -OutFile $gwPath
    Copy-Item -Path $gwPath -Destination $projectGwPath -Force
    Write-Host "Downloaded wokwigw.exe successfully." -ForegroundColor Green
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " All dependencies verified and ready! " -ForegroundColor Green
Write-Host " You can now compile or run your simulation. " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
