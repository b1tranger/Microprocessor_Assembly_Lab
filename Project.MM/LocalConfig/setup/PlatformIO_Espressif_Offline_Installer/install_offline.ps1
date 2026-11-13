[CmdletBinding()]
param(
    [switch]$GlobalProfile = $false
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "utf-8"

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

# Dependency search paths (localized folder prioritized, then offline_bundle)
$wheelsDir = if (Test-Path (Join-Path $scriptDir "wheels")) {
    Join-Path $scriptDir "wheels"
} elseif (Test-Path (Join-Path $scriptDir "offline_bundle\wheels")) {
    Join-Path $scriptDir "offline_bundle\wheels"
} else {
    $null
}

$localPioDir = Join-Path $scriptDir ".platformio"
$pioCacheZip = if (Test-Path (Join-Path $scriptDir "offline_bundle\platformio_cache.zip")) {
    Join-Path $scriptDir "offline_bundle\platformio_cache.zip"
} elseif (Test-Path (Join-Path $scriptDir "platformio_cache.zip")) {
    Join-Path $scriptDir "platformio_cache.zip"
} else {
    $null
}

$gwSource = if (Test-Path (Join-Path $scriptDir "wokwigw.exe")) {
    Join-Path $scriptDir "wokwigw.exe"
} elseif (Test-Path (Join-Path $scriptDir "offline_bundle\wokwigw.exe")) {
    Join-Path $scriptDir "offline_bundle\wokwigw.exe"
} else {
    $null
}

# Locate LocalConfig if present (Project.MM or parent directory)
$parentDir = Split-Path -Parent $scriptDir
$projectDir = Join-Path $parentDir "LocalConfig"
if (-not (Test-Path $projectDir)) {
    $altProjectDir = Join-Path (Split-Path -Parent $parentDir) "LocalConfig"
    if (Test-Path $altProjectDir) { $projectDir = $altProjectDir }
}
$projectGwPath = if (Test-Path $projectDir) { Join-Path $projectDir "wokwigw.exe" } else { $null }

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " PlatformIO Espressif 32 - 100% OFFLINE Installer " -ForegroundColor Cyan
Write-Host " Zero Internet Connection Required " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Verify localized dependency presence
if (-not $wheelsDir -or -not (Test-Path $wheelsDir)) {
    Write-Host "[ERROR] Offline Python wheels not found!" -ForegroundColor Red
    Write-Host "Expected 'wheels/' inside: $scriptDir" -ForegroundColor Red
    exit 1
}

$hasLocalPio = (Test-Path (Join-Path $localPioDir "packages")) -and (Test-Path (Join-Path $localPioDir "platforms"))
if (-not $hasLocalPio -and -not $pioCacheZip) {
    Write-Host "[ERROR] Toolchains not found!" -ForegroundColor Red
    Write-Host "Expected '.platformio/' or 'platformio_cache.zip' inside: $scriptDir" -ForegroundColor Red
    exit 1
}

# 2. Check Python
Write-Host "`n[1/4] Checking Python installation..." -ForegroundColor Yellow
try {
    $pythonCmd = Get-Command python -ErrorAction Stop
    $pythonVersion = & $pythonCmd.Source --version 2>&1
    Write-Host "Found: $pythonVersion ($($pythonCmd.Source))" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Python is not installed or not in PATH!" -ForegroundColor Red
    Write-Host "Please install Python 3.10+ and check 'Add Python to PATH'." -ForegroundColor Red
    exit 1
}

# 3. Install PlatformIO CLI from localized wheels
Write-Host "`n[2/4] Installing PlatformIO CLI offline from local wheels..." -ForegroundColor Yellow
Write-Host "Wheels source: $wheelsDir" -ForegroundColor Cyan
python -m pip install --no-index --find-links="$wheelsDir" platformio
if ($LASTEXITCODE -ne 0) {
    Write-Host "[RETRY] Attempting with --user flag..." -ForegroundColor Yellow
    python -m pip install --no-index --find-links="$wheelsDir" --user platformio
}

$pioVersion = python -m platformio --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "PlatformIO CLI ready: $pioVersion" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Failed to install PlatformIO from offline wheels." -ForegroundColor Red
    exit 1
}

# Ensure Scripts directory on PATH
try {
    $pyScriptsDir = python -c "import sys, pathlib; print(pathlib.Path(sys.executable).parent / 'Scripts')" 2>$null
    if ($pyScriptsDir -and (Test-Path $pyScriptsDir)) {
        if (-not (Get-Command pio -ErrorAction SilentlyContinue)) {
            $env:PATH = "$pyScriptsDir;$env:PATH"
            $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
            if ($userPath -notlike "*$pyScriptsDir*") {
                [Environment]::SetEnvironmentVariable("Path", "$userPath;$pyScriptsDir", "User")
            }
        }
    }
} catch {
    # Non-fatal
}

# 4. Configure Espressif Toolchains & Framework
Write-Host "`n[3/4] Configuring Espressif 32 toolchains..." -ForegroundColor Yellow

if ($GlobalProfile) {
    # Optional: Deploy to global ~/.platformio
    $pioHome = Join-Path $env:USERPROFILE ".platformio"
    if (-not (Test-Path $pioHome)) {
        New-Item -ItemType Directory -Path $pioHome -Force | Out-Null
    }
    if ($hasLocalPio) {
        Write-Host "Copying toolchains to global user directory: $pioHome..." -ForegroundColor Cyan
        robocopy (Join-Path $localPioDir "packages") (Join-Path $pioHome "packages") /E /MT:16 /NFL /NDL /NP
        robocopy (Join-Path $localPioDir "platforms") (Join-Path $pioHome "platforms") /E /MT:16 /NFL /NDL /NP
    } elseif ($pioCacheZip) {
        Write-Host "Unpacking archive to $pioHome..." -ForegroundColor Cyan
        Expand-Archive -Path $pioCacheZip -DestinationPath $pioHome -Force
    }
    [Environment]::SetEnvironmentVariable("PLATFORMIO_CORE_DIR", $null, "User")
    Remove-Item env:PLATFORMIO_CORE_DIR -ErrorAction SilentlyContinue
    Write-Host "Configured for global ~/.platformio directory." -ForegroundColor Green
} else {
    # Default: 100% Localized inside installer folder
    if (-not $hasLocalPio -and $pioCacheZip) {
        Write-Host "Unpacking cached toolchains into localized folder: $localPioDir..." -ForegroundColor Cyan
        Expand-Archive -Path $pioCacheZip -DestinationPath $localPioDir -Force
    }
    
    $env:PLATFORMIO_CORE_DIR = $localPioDir
    [Environment]::SetEnvironmentVariable("PLATFORMIO_CORE_DIR", $localPioDir, "User")
    Write-Host "PLATFORMIO_CORE_DIR localized to: $localPioDir" -ForegroundColor Green
    Write-Host "All builds and compilers will run directly from this folder." -ForegroundColor Green
}

# 5. Set up Wokwi Gateway (if applicable)
Write-Host "`n[4/4] Verifying Wokwi IoT Gateway..." -ForegroundColor Yellow
if ($projectGwPath -and $gwSource -and (Test-Path $gwSource)) {
    Copy-Item -Path $gwSource -Destination $projectGwPath -Force
    Write-Host "wokwigw.exe verified in $projectGwPath." -ForegroundColor Green
} elseif ($gwSource -and (Test-Path $gwSource)) {
    Write-Host "wokwigw.exe present in localized folder ($gwSource)." -ForegroundColor Green
} else {
    Write-Host "Wokwi gateway skipped." -ForegroundColor Gray
}

# 6. Build validation test
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " Validating Offline Environment " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

if ($projectDir -and (Test-Path $projectDir)) {
    Push-Location $projectDir
    try {
        Write-Host "Testing compilation on $projectDir..." -ForegroundColor Cyan
        python -u -m platformio run
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n[SUCCESS] Offline environment validated! Firmware compiled successfully." -ForegroundColor Green
            $binPath = Join-Path $projectDir ".pio\build\esp32dev\firmware.bin"
            if (Test-Path $binPath) {
                $binSize = (Get-Item $binPath).Length
                Write-Host "Generated: firmware.bin ($binSize bytes)" -ForegroundColor Green
            }
        } else {
            Write-Host "`n[WARNING] First build test returned code $LASTEXITCODE. Toolchains are installed." -ForegroundColor Yellow
        }
    } finally {
        Pop-Location
    }
} else {
    python -m platformio pkg list -g
    Write-Host "`n[SUCCESS] PlatformIO Core & Espressif 32 toolchains localized and ready!" -ForegroundColor Green
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " 100% OFFLINE SETUP COMPLETE! " -ForegroundColor Green
Write-Host " Dependencies are fully localized in: " -ForegroundColor Green
Write-Host " $scriptDir" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

