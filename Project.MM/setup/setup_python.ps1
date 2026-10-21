<#
.SYNOPSIS
    Automated Python 3 Installer for Windows.
.DESCRIPTION
    Checks for an existing Python installation. If missing, attempts installation
    via winget (Windows Package Manager) or directly downloads and runs the official
    python.org installer with PATH automatically configured.
#>

function Refresh-EnvironmentPath {
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:PATH = "$machinePath;$userPath"
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Automated Python Setup for Windows " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Check if Python is already installed and functional
Write-Host "`n[1/3] Detecting Python in current environment..." -ForegroundColor Yellow
$pythonInstalled = $false

try {
    $pyCmd = Get-Command python -ErrorAction Stop
    $pyVer = & $pyCmd.Source --version 2>&1
    Write-Host "[OK] Python is already installed: $pyVer" -ForegroundColor Green
    Write-Host "Path: $($pyCmd.Source)" -ForegroundColor Green
    $pythonInstalled = $true
} catch {
    # Try Python launcher 'py'
    try {
        $pyLauncher = Get-Command py -ErrorAction Stop
        $pyVer = & $pyLauncher.Source -0 2>&1
        Write-Host "[OK] Python Launcher (py.exe) is available:" -ForegroundColor Green
        Write-Host $pyVer -ForegroundColor Green
        $pythonInstalled = $true
    } catch {
        Write-Host "Python was not detected in PATH." -ForegroundColor Gray
    }
}

if ($pythonInstalled) {
    Write-Host "`nPython is ready! You can now proceed to run:" -ForegroundColor Green
    Write-Host "  .\install_dependencies.bat" -ForegroundColor Cyan
    exit 0
}

# 2. Attempt installation
Write-Host "`n[2/3] Installing Python 3.12 (64-bit)..." -ForegroundColor Yellow

$installedSuccessfully = $false

# Method A: Try winget if available
$wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
if ($wingetCmd) {
    Write-Host "Attempting installation via Windows Package Manager (winget)..." -ForegroundColor Cyan
    try {
        & winget install --id Python.Python.3.12 --exact --silent --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -eq 0) {
            $installedSuccessfully = $true
            Write-Host "winget installation completed successfully." -ForegroundColor Green
        } else {
            Write-Host "winget returned non-zero code ($LASTEXITCODE). Falling back to direct installer..." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "winget execution failed. Falling back to direct installer..." -ForegroundColor Yellow
    }
}

# Method B: Fallback to direct download from python.org
if (-not $installedSuccessfully) {
    $installerUrl = "https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe"
    $installerPath = Join-Path $env:TEMP "python-3.12.8-amd64.exe"

    Write-Host "Downloading official installer from python.org..." -ForegroundColor Cyan
    Write-Host "URL: $installerUrl" -ForegroundColor Gray
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
        Write-Host "Download complete. Running silent installer (adding to PATH)..." -ForegroundColor Cyan
        
        $process = Start-Process -FilePath $installerPath -ArgumentList "/quiet", "InstallAllUsers=0", "PrependPath=1", "Include_test=0", "SimpleInstall=1" -Wait -PassThru
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            $installedSuccessfully = $true
            Write-Host "Official installer completed successfully." -ForegroundColor Green
        } else {
            Write-Host "[ERROR] Python installer exited with code $($process.ExitCode)." -ForegroundColor Red
        }
    } catch {
        Write-Host "[ERROR] Failed to download or execute Python installer: $_" -ForegroundColor Red
    } finally {
        if (Test-Path $installerPath) {
            Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
        }
    }
}

# 3. Refresh PATH and Verify
Write-Host "`n[3/3] Refreshing session environment and verifying..." -ForegroundColor Yellow
Refresh-EnvironmentPath

# If python is not yet picked up by current session, check standard install location
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    $localPythonDir = Join-Path $env:LOCALAPPDATA "Programs\Python\Python312"
    $localScriptsDir = Join-Path $localPythonDir "Scripts"
    if (Test-Path (Join-Path $localPythonDir "python.exe")) {
        $env:PATH = "$localPythonDir;$localScriptsDir;$env:PATH"
        Write-Host "Registered local Python path to current session." -ForegroundColor Cyan
    }
}

try {
    $verifyCmd = Get-Command python -ErrorAction Stop
    $verifyVer = & $verifyCmd.Source --version 2>&1
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host " [SUCCESS] Python is installed and verified! " -ForegroundColor Green
    Write-Host " Version: $verifyVer" -ForegroundColor Green
    Write-Host " Path   : $($verifyCmd.Source)" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Next step: Run 'install_dependencies.bat' to install PlatformIO." -ForegroundColor Cyan
} catch {
    Write-Host "`n[NOTICE] Python installation finished, but requires reopening the terminal." -ForegroundColor Yellow
    Write-Host "Please close this window and open a new PowerShell/Command Prompt window to use Python." -ForegroundColor Yellow
}
