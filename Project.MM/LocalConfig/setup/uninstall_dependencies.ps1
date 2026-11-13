<#
.SYNOPSIS
    Automated Uninstaller for ESP32 NAS & Web Server Setup Environment.
.DESCRIPTION
    Reverts changes made by scripts in Project.MM/LocalConfig/setup/:
    1. Terminates any running Wokwi IoT Gateway (wokwigw.exe) processes.
    2. Removes the Windows Firewall rule "Wokwi Gateway NAS" (Port 9080).
    3. Cleans up environment variables (PLATFORMIO_CORE_DIR).
    4. Cleans up generated simulation build artifacts (.pio/ and duplicate wokwigw.exe).
    5. Optionally uninstalls PlatformIO CLI and cleans toolchain directories (-FullCleanup).
#>

[CmdletBinding()]
param(
    [switch]$FullCleanup = $false,       # Uninstalls PlatformIO CLI and deletes unzipped toolchains
    [switch]$KeepFirewallRule = $false   # Skip firewall rule deletion
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$localConfigDir = Split-Path -Parent $scriptDir

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   ESP32 NAS Project - Automated Uninstaller      " -ForegroundColor Cyan
Write-Host " Reverting changes made by setup scripts...      " -ForegroundColor Yellow
Write-Host " Target Workspace: $localConfigDir" -ForegroundColor Gray
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Stop any active wokwigw process
Write-Host "`n[1/5] Stopping any running Wokwi Gateway (wokwigw) processes..." -ForegroundColor Yellow
$gwProcesses = Get-Process -Name "wokwigw" -ErrorAction SilentlyContinue
if ($gwProcesses) {
    $gwProcesses | Stop-Process -Force
    Write-Host "[SUCCESS] Stopped $($gwProcesses.Count) running wokwigw process(es)." -ForegroundColor Green
} else {
    Write-Host "[OK] No active wokwigw process found." -ForegroundColor Gray
}

# 2. Remove Windows Firewall Rule (Port 9080)
if (-not $KeepFirewallRule) {
    Write-Host "`n[2/5] Removing Windows Firewall Inbound Rule ('Wokwi Gateway NAS')..." -ForegroundColor Yellow
    try {
        $existing = Get-NetFirewallRule -DisplayName "Wokwi Gateway NAS" -ErrorAction SilentlyContinue
        if ($existing) {
            Remove-NetFirewallRule -DisplayName "Wokwi Gateway NAS" -ErrorAction Stop
            Write-Host "[SUCCESS] Windows Firewall rule 'Wokwi Gateway NAS' (Port 9080) removed!" -ForegroundColor Green
        } else {
            Write-Host "[OK] No firewall rule named 'Wokwi Gateway NAS' found." -ForegroundColor Gray
        }
    } catch {
        Write-Host "[WARNING] Administrative privileges required to remove Windows Firewall rule." -ForegroundColor Yellow
        Write-Host "          Run uninstall_dependencies.bat as Administrator to remove the firewall rule." -ForegroundColor Gray
    }
} else {
    Write-Host "`n[2/5] Skipping Windows Firewall rule removal as requested." -ForegroundColor Gray
}

# 3. Clean Environment Variables (PLATFORMIO_CORE_DIR)
Write-Host "`n[3/5] Cleaning up environment variables..." -ForegroundColor Yellow
$userPioCore = [System.Environment]::GetEnvironmentVariable("PLATFORMIO_CORE_DIR", "User")
if ($userPioCore) {
    [System.Environment]::SetEnvironmentVariable("PLATFORMIO_CORE_DIR", $null, "User")
    Write-Host "[SUCCESS] Removed User environment variable PLATFORMIO_CORE_DIR ($userPioCore)." -ForegroundColor Green
} else {
    Write-Host "[OK] PLATFORMIO_CORE_DIR was not set in User environment." -ForegroundColor Gray
}
if ($env:PLATFORMIO_CORE_DIR) {
    Remove-Item env:PLATFORMIO_CORE_DIR -ErrorAction SilentlyContinue
}

# 4. Clean Generated Build Artifacts & Copied Binaries
Write-Host "`n[4/5] Cleaning up generated build artifacts in LocalConfig..." -ForegroundColor Yellow

$pioBuildDir = Join-Path $localConfigDir ".pio"
if (Test-Path $pioBuildDir) {
    Write-Host "Removing compiled firmware and build artifacts in .pio/..." -ForegroundColor Cyan
    Remove-Item -Path $pioBuildDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[SUCCESS] Removed $pioBuildDir." -ForegroundColor Green
} else {
    Write-Host "[OK] No .pio build directory found." -ForegroundColor Gray
}

$copiedGw = Join-Path $localConfigDir "wokwigw.exe"
$setupGw = Join-Path $scriptDir "wokwigw.exe"
if ((Test-Path $copiedGw) -and (Test-Path $setupGw)) {
    Remove-Item -Path $copiedGw -Force -ErrorAction SilentlyContinue
    Write-Host "[SUCCESS] Removed duplicate $copiedGw (preserved standalone binary in setup/)." -ForegroundColor Green
} else {
    Write-Host "[OK] LocalConfig/wokwigw.exe clean." -ForegroundColor Gray
}

# 5. Clean Python Package & Local Toolchain Cache (Optional / Full Cleanup)
Write-Host "`n[5/5] Checking PlatformIO CLI package & toolchains..." -ForegroundColor Yellow
if ($FullCleanup) {
    Write-Host "Performing Full Cleanup (-FullCleanup flag detected)..." -ForegroundColor Cyan
    try {
        $pioCheck = Get-Command pio -ErrorAction SilentlyContinue
        if ($pioCheck) {
            Write-Host "Uninstalling PlatformIO CLI via pip..." -ForegroundColor Cyan
            python -m pip uninstall -y platformio
            Write-Host "[SUCCESS] PlatformIO CLI uninstalled." -ForegroundColor Green
        }
    } catch {
        Write-Host "[WARNING] Could not uninstall PlatformIO CLI: $_" -ForegroundColor Yellow
    }

    $offlinePio = Join-Path $scriptDir "PlatformIO_Espressif_Offline_Installer\.platformio"
    if (Test-Path $offlinePio) {
        Write-Host "Removing unzipped toolchains in $offlinePio..." -ForegroundColor Cyan
        Remove-Item -Path $offlinePio -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[SUCCESS] Local unzipped toolchains removed (zipped archive remains)." -ForegroundColor Green
    }
} else {
    Write-Host "[INFO] PlatformIO CLI and toolchain cache were preserved." -ForegroundColor Cyan
    Write-Host "       To also uninstall PlatformIO CLI and purge extracted toolchains, run:" -ForegroundColor Gray
    Write-Host "       .\uninstall_dependencies.bat -FullCleanup" -ForegroundColor White
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "      Uninstallation Complete Successfully!       " -ForegroundColor Green
Write-Host " All simulation and network changes have been reverted." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

