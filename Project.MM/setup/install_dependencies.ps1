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
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUNBUFFERED = "1"

Write-Host "==================================================" -ForegroundColor Cyan

# 1. Check Python
Write-Host "`n[1/4] Checking Python installation..." -ForegroundColor Yellow
$pythonAvailable = $false
try {
    $pythonCmd = Get-Command python -ErrorAction Stop
    $pythonVersion = & $pythonCmd.Source --version 2>&1
    Write-Host "Found: $pythonVersion ($($pythonCmd.Source))" -ForegroundColor Green
    $pythonAvailable = $true
} catch {
    Write-Host "[WARNING] Python is not installed or not in PATH." -ForegroundColor Yellow
    $setupPythonScript = Join-Path $scriptDir "setup_python.ps1"
    if (Test-Path $setupPythonScript) {
        Write-Host "Launching automated Python setup script..." -ForegroundColor Cyan
        & $setupPythonScript
        # Refresh current session PATH after running setup
        $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        $env:PATH = "$machinePath;$userPath"

        # Check standard default installation folder if needed
        $localPythonDir = Join-Path $env:LOCALAPPDATA "Programs\Python\Python312"
        $localScriptsDir = Join-Path $localPythonDir "Scripts"
        if (Test-Path (Join-Path $localPythonDir "python.exe")) {
            $env:PATH = "$localPythonDir;$localScriptsDir;$env:PATH"
        }

        try {
            $pythonCmd = Get-Command python -ErrorAction Stop
            $pythonVersion = & $pythonCmd.Source --version 2>&1
            Write-Host "[OK] Python is now ready: $pythonVersion" -ForegroundColor Green
            $pythonAvailable = $true
        } catch {
            Write-Host "[ERROR] Python installation completed but was not detected in the current terminal session." -ForegroundColor Red
            Write-Host "Please restart your terminal/Command Prompt and run this script again." -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "[ERROR] setup_python.ps1 not found." -ForegroundColor Red
        Write-Host "Please install Python 3.10+ from https://www.python.org/ and check 'Add Python to PATH'." -ForegroundColor Red
        exit 1
    }
}

# 2. Install / Upgrade PlatformIO Core
Write-Host "`n[2/4] Installing / Upgrading PlatformIO CLI..." -ForegroundColor Yellow
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
Write-Host "`n[3/4] Verifying Wokwi IoT Gateway (wokwigw.exe)..." -ForegroundColor Yellow

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

# 4. Check Espressif 32 Toolchains & Framework
Write-Host "`n[4/4] Verifying Espressif 32 toolchains & framework..." -ForegroundColor Yellow
$pioPackagesDir = Join-Path $env:USERPROFILE ".platformio\packages"
$xtensaTool = Join-Path $pioPackagesDir "toolchain-xtensa-esp-elf"
$arduinoEsp32 = Join-Path $pioPackagesDir "framework-arduinoespressif32"
$localConfigDir = Join-Path $projectDir "LocalConfig"

if ((Test-Path $xtensaTool) -and (Test-Path $arduinoEsp32)) {
    Write-Host "Espressif 32 toolchain and Arduino core are cached and ready." -ForegroundColor Green
} else {
    Write-Host "Downloading Espressif 32 toolchains & framework packages (~600MB)..." -ForegroundColor Cyan
    Write-Host "Live download progress will be shown below:" -ForegroundColor Gray
    python -u -m platformio pkg install -d $localConfigDir
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Espressif 32 packages installed successfully." -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Package pre-installation returned non-zero code. build_firmware.bat will retry upon compilation." -ForegroundColor Yellow
    }
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " All dependencies verified and ready! " -ForegroundColor Green
Write-Host " You can now compile or run your simulation. " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
