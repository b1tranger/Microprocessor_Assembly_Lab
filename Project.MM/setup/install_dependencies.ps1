<#
.SYNOPSIS
    Automated Dependency Installer for ESP32 NAS & Web Server Simulation.
.DESCRIPTION
    Verifies Python, installs/updates PlatformIO CLI, and ensures toolchains are ready.
#>

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$projectDir = Split-Path -Parent $scriptDir
$projectGwPath = Join-Path $projectDir "LocalConfig\wokwigw.exe"
$gwPath = Join-Path $scriptDir "wokwigw.exe"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " ESP32 NAS Project - Dependency Verification " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Check Python
Write-Host "`n[1/3] Checking Python installation..." -ForegroundColor Yellow
try {
    $pythonCmd = Get-Command python -ErrorAction Stop
    $pythonVersion = & $pythonCmd.Source --version 2>&1
    Write-Host "Found: $pythonVersion ($($pythonCmd.Source))" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Python is not installed or not in PATH!" -ForegroundColor Red
    Write-Host "Please install Python 3.10+ from https://www.python.org/ and check 'Add Python to PATH'." -ForegroundColor Red
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

# 2b. Ensure Python Scripts directory is on PATH for 'pio' command
try {
    $pyScriptsDir = python -c "import sys, pathlib; print(pathlib.Path(sys.executable).parent / 'Scripts')" 2>$null
    if ($pyScriptsDir -and (Test-Path $pyScriptsDir)) {
        if (-not (Get-Command pio -ErrorAction SilentlyContinue)) {
            Write-Host "Configuring session PATH for PlatformIO CLI..." -ForegroundColor Cyan
            $env:PATH = "$pyScriptsDir;$env:PATH"
            $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
            if ($userPath -notlike "*$pyScriptsDir*") {
                [Environment]::SetEnvironmentVariable("Path", "$userPath;$pyScriptsDir", "User")
                Write-Host "Added $pyScriptsDir to CurrentUser PATH permanently." -ForegroundColor Green
            }
        }
    }
} catch {
    # Non-fatal warning
    Write-Warning "Could not automatically register Python Scripts to PATH."
}

# 3. Check wokwigw.exe
Write-Host "`n[3/3] Verifying Wokwi IoT Gateway (wokwigw.exe)..." -ForegroundColor Yellow

if (Test-Path $gwPath) {
    Write-Host "wokwigw.exe is present in setup/ folder." -ForegroundColor Green
    if (-not (Test-Path $projectGwPath)) {
        Write-Host "Copying wokwigw.exe to LocalConfig/..." -ForegroundColor Cyan
        Copy-Item -Path $gwPath -Destination $projectGwPath -Force
    }
} else {
    Write-Host "[WARNING] wokwigw.exe not found in setup/. Downloading latest release..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/wokwi/wokwigw/releases/latest/download/wokwigw.exe" -OutFile $gwPath
        Copy-Item -Path $gwPath -Destination $projectGwPath -Force
        Write-Host "Downloaded wokwigw.exe successfully." -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to download wokwigw.exe: $_" -ForegroundColor Red
    }
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " All dependencies verified and ready! " -ForegroundColor Green
Write-Host " You can now compile or run your simulation. " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
