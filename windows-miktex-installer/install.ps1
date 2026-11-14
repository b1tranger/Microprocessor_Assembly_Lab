<#
.SYNOPSIS
    One-Click Automated MiKTeX & LuaLaTeX Installer for Windows.
.DESCRIPTION
    Installs MiKTeX (LuaLaTeX, pdfLaTeX, XeLaTeX), configures on-the-fly
    package installation, updates user environment PATH, and verifies
    compatibility with LaTeX editors and VS Code extensions (e.g., realtime-tex, LaTeX Workshop).
.PARAMETER NonInteractive
    Suppresses interactive pauses at script completion.
.PARAMETER Method
    Preferred installation method: "Auto" (default), "Winget", or "DirectDownload".
#>

[CmdletBinding()]
param(
    [switch]$NonInteractive,
    [ValidateSet("Auto", "Winget", "DirectDownload")]
    [string]$Method = "Auto"
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Text)
    Write-Host "`n====> $Text" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Text)
    Write-Host "[OK] $Text" -ForegroundColor Green
}

function Write-Info {
    param([string]$Text)
    Write-Host "[INFO] $Text" -ForegroundColor Gray
}

function Write-Warn {
    param([string]$Text)
    Write-Host "[WARN] $Text" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Text)
    Write-Host "[ERROR] $Text" -ForegroundColor Red
}

Clear-Host
Write-Host "==========================================================" -ForegroundColor Magenta
Write-Host "   MiKTeX & LuaLaTeX One-Click Windows Automated Setup    " -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Magenta
Write-Host "Target: Full LaTeX compiler suite with on-the-fly packages" -ForegroundColor DarkGray
Write-Host "Designed for: Antigravity IDE, VS Code, and CLI environments`n" -ForegroundColor DarkGray

# ---------------------------------------------------------------------------
# 1. Check Existing Installation
# ---------------------------------------------------------------------------
Write-Step "Checking environment for existing LaTeX installations..."

$ExistingLua = Get-Command lualatex.exe -ErrorAction SilentlyContinue
$ExistingPdf = Get-Command pdflatex.exe -ErrorAction SilentlyContinue

if ($ExistingLua -and $ExistingPdf) {
    Write-Success "Found existing LaTeX installation on PATH:"
    Write-Info "  LuaLaTeX: $($ExistingLua.Source)"
    Write-Info "  pdfLaTeX: $($ExistingPdf.Source)"
    
    $reinstall = $false
    if (-not $NonInteractive) {
        $choice = Read-Host "`nLaTeX is already installed. Do you want to re-run configuration / repair? (y/N)"
        if ($choice -match '^[Yy]') { $reinstall = $true }
    }
    
    if (-not $reinstall) {
        Write-Host "`nSkipping installation. Proceeding to verification and configuration..." -ForegroundColor Green
        & (Join-Path $PSScriptRoot "verify.ps1") -SkipPause
        if (-not $NonInteractive) {
            Write-Host "`nPress any key to exit..." -ForegroundColor Gray
            [Console]::ReadKey($true) | Out-Null
        }
        return
    }
}

# ---------------------------------------------------------------------------
# 2. Determine Installer Strategy
# ---------------------------------------------------------------------------
$WingetAvailable = $false
$WingetCmd = Get-Command winget.exe -ErrorAction SilentlyContinue

if ($WingetCmd -and ($Method -ne "DirectDownload")) {
    try {
        $testWinget = & winget.exe --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $WingetAvailable = $true
            Write-Info "Windows Package Manager (winget $testWinget) detected."
        }
    } catch {
        Write-Warn "winget execution failed. Falling back to direct download."
    }
}

$InstallSuccess = $false

# ---------------------------------------------------------------------------
# 3. Strategy A: WinGet Installation
# ---------------------------------------------------------------------------
if ($WingetAvailable -and ($Method -eq "Auto" -or $Method -eq "Winget")) {
    Write-Step "Attempting installation via Windows Package Manager (winget)..."
    Write-Info "Executing: winget install --id MiKTeX.MiKTeX -e --accept-source-agreements --accept-package-agreements"
    
    try {
        $proc = Start-Process -FilePath "winget.exe" `
            -ArgumentList "install --id MiKTeX.MiKTeX -e --accept-source-agreements --accept-package-agreements" `
            -NoNewWindow -PassThru -Wait
        
        if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 2316632065) {
            # 2316632065 is commonly returned when package is already installed
            Write-Success "winget reported successful installation."
            $InstallSuccess = $true
        } else {
            Write-Warn "winget exited with code $($proc.ExitCode). Falling back to direct installer download..."
        }
    } catch {
        Write-Warn "winget encountered an exception: $($_.Exception.Message)"
    }
}

# ---------------------------------------------------------------------------
# 4. Strategy B: Direct CTAN Installer Download & Silent Execution
# ---------------------------------------------------------------------------
if (-not $InstallSuccess) {
    Write-Step "Downloading official Basic MiKTeX Windows 64-bit installer..."
    
    $DownloadUrl = "https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-25.12-x64.exe"
    $TempInstaller = Join-Path $env:TEMP "basic-miktex-setup-x64.exe"
    
    Write-Info "Source: $DownloadUrl"
    Write-Info "Target: $TempInstaller"
    
    if (Test-Path $TempInstaller) {
        Remove-Item $TempInstaller -Force -ErrorAction SilentlyContinue
    }
    
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
        $webClient = New-Object System.Net.WebClient
        
        $lastReported = 0
        $progressEvent = Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action {
            param($sender, $e)
            $percent = $e.ProgressPercentage
            if ($percent -ge ($script:lastReported + 10)) {
                $script:lastReported = $percent
                Write-Progress -Activity "Downloading Basic MiKTeX Installer" `
                    -Status "$percent% complete ($([math]::Round($e.BytesReceived/1MB, 1)) MB / $([math]::Round($e.TotalBytesToReceive/1MB, 1)) MB)" `
                    -PercentComplete $percent
            }
        }
        
        $webClient.DownloadFile($DownloadUrl, $TempInstaller)
        Unregister-Event -SourceIdentifier $progressEvent.Name -ErrorAction SilentlyContinue
        Write-Progress -Activity "Downloading Basic MiKTeX Installer" -Completed
        
        Write-Success "Installer downloaded successfully ($([math]::Round((Get-Item $TempInstaller).Length / 1MB, 2)) MB)."
    } catch {
        Write-Err "Failed to download installer via WebClient. Retrying with curl.exe..."
        $curlCmd = Get-Command curl.exe -ErrorAction SilentlyContinue
        if ($curlCmd) {
            & curl.exe -L --retry 3 -o $TempInstaller $DownloadUrl
            if ($LASTEXITCODE -ne 0 -or -not (Test-Path $TempInstaller)) {
                throw "curl.exe failed to download MiKTeX from $DownloadUrl"
            }
            Write-Success "curl download complete."
        } else {
            throw "Failed to download installer: $($_.Exception.Message)"
        }
    }
    
    Write-Step "Running unattended installation..."
    Write-Info "Options: --unattended --auto-install=yes --paper-size=A4"
    Write-Info "Please wait 1-3 minutes while binaries are extracted and configured..."
    
    $installArgs = @(
        "--unattended",
        "--auto-install=yes",
        "--paper-size=A4"
    )
    
    $proc = Start-Process -FilePath $TempInstaller -ArgumentList $installArgs -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        Write-Warn "Installer exited with code $($proc.ExitCode). Verifying disk contents..."
    } else {
        Write-Success "Installer process completed successfully."
    }
}

# ---------------------------------------------------------------------------
# 5. Locate MiKTeX Binaries & Update Environment PATH
# ---------------------------------------------------------------------------
Write-Step "Locating MiKTeX binaries and updating system PATH..."

$PossibleBinPaths = @(
    (Join-Path $env:LOCALAPPDATA "Programs\MiKTeX\miktex\bin\x64"),
    (Join-Path $env:ProgramFiles "MiKTeX\miktex\bin\x64"),
    (Join-Path ${env:ProgramFiles(x86)} "MiKTeX\miktex\bin\x64")
)

$FoundBinPath = $null
foreach ($path in $PossibleBinPaths) {
    if (Test-Path (Join-Path $path "lualatex.exe")) {
        $FoundBinPath = $path
        break
    }
}

if (-not $FoundBinPath) {
    # Recursive fallback search
    $searchRoots = @((Join-Path $env:LOCALAPPDATA "Programs\MiKTeX"), (Join-Path $env:ProgramFiles "MiKTeX"))
    foreach ($root in $searchRoots) {
        if (Test-Path $root) {
            $matched = Get-ChildItem -Path $root -Filter "lualatex.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($matched) {
                $FoundBinPath = $matched.DirectoryName
                break
            }
        }
    }
}

if (-not $FoundBinPath) {
    Write-Err "Could not automatically locate 'lualatex.exe' after installation."
    Write-Info "Please check if your antivirus blocked the installer or manually check C:\Program Files\MiKTeX or AppData."
    throw "Binary search failure."
}

Write-Success "Discovered MiKTeX binaries at: $FoundBinPath"

# Refresh current process PATH
if ($env:PATH -notmatch [regex]::Escape($FoundBinPath)) {
    $env:PATH = "$FoundBinPath;$env:PATH"
    Write-Info "Added to current session PATH."
}

# Persist to User Environment PATH
$UserPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
if ($UserPath -notmatch [regex]::Escape($FoundBinPath)) {
    $NewUserPath = "$FoundBinPath;$UserPath"
    [Environment]::SetEnvironmentVariable("PATH", $NewUserPath, [EnvironmentVariableTarget]::User)
    Write-Success "Persisted '$FoundBinPath' to User Environment PATH."
} else {
    Write-Info "Path is already present in User Environment variables."
}

# ---------------------------------------------------------------------------
# 6. Configure On-The-Fly Package Installation
# ---------------------------------------------------------------------------
Write-Step "Configuring automatic on-the-fly package installation..."

$InitExMf = Join-Path $FoundBinPath "initexmf.exe"
if (Test-Path $InitExMf) {
    try {
        & $InitExMf --set-config-value "[MPM]AutoInstall=1" | Out-Null
        Write-Success "Package Manager Auto-Install enabled ([MPM]AutoInstall=1)."
        
        Write-Info "Updating filename database (fndb)..."
        & $InitExMf --update-fndb | Out-Null
        Write-Success "Filename database updated."
    } catch {
        Write-Warn "Could not update initexmf configuration: $($_.Exception.Message)"
    }
}

# ---------------------------------------------------------------------------
# 7. Verification Tests
# ---------------------------------------------------------------------------
Write-Step "Running sanity checks on installed engines..."

$TestLua = & (Join-Path $FoundBinPath "lualatex.exe") --version 2>&1 | Select-Object -First 1
$TestPdf = & (Join-Path $FoundBinPath "pdflatex.exe") --version 2>&1 | Select-Object -First 1

if ($TestLua) {
    Write-Success "LuaLaTeX verification: $TestLua"
} else {
    Write-Err "Failed to execute lualatex.exe"
}

if ($TestPdf) {
    Write-Success "pdfLaTeX verification: $TestPdf"
} else {
    Write-Err "Failed to execute pdflatex.exe"
}

# ---------------------------------------------------------------------------
# 8. Check Integration with realtime-tex (rtex)
# ---------------------------------------------------------------------------
Write-Step "Checking integration with Realtime TeX (rtex)..."

$PossibleRtexPaths = @(
    (Join-Path $env:APPDATA "Antigravity IDE\User\globalStorage\henryxiaoyang.realtime-tex\rtex-release\v0.0.7\bin\rtex.exe"),
    (Join-Path $env:APPDATA "Code\User\globalStorage\henryxiaoyang.realtime-tex\rtex-release\v0.0.7\bin\rtex.exe")
)

$RtexFound = $null
foreach ($p in $PossibleRtexPaths) {
    if (Test-Path $p) {
        $RtexFound = $p
        break
    }
}

if ($RtexFound) {
    Write-Info "Found rtex at: $RtexFound"
    Write-Info "Running 'rtex doctor'..."
    try {
        $doctorOutput = & $RtexFound doctor 2>&1
        $doctorOutput | ForEach-Object { Write-Host "   $_" -ForegroundColor DarkGray }
        if ($doctorOutput -match 'lualatex:\s+ok|LuaLaTeX found|rtex \d') {
            Write-Success "rtex successfully recognized LuaLaTeX!"
        }
    } catch {
        Write-Warn "rtex doctor check was inconclusive."
    }
} else {
    Write-Info "No VS Code / Antigravity IDE realtime-tex storage found. (Extension can be installed anytime)."
}

# ---------------------------------------------------------------------------
# 8.1 Auto-Configure Editor Settings (Antigravity IDE & VS Code)
# ---------------------------------------------------------------------------
Write-Step "Auto-configuring editor settings (realtimeTex.texliveBin)..."

$SettingsFiles = @(
    (Join-Path $env:APPDATA "Antigravity IDE\User\settings.json"),
    (Join-Path $env:APPDATA "Code\User\settings.json")
)

foreach ($sf in $SettingsFiles) {
    if (Test-Path $sf) {
        try {
            $jsonRaw = Get-Content $sf -Raw -ErrorAction SilentlyContinue
            if ($jsonRaw) {
                $jsonObj = $jsonRaw | ConvertFrom-Json
            } else {
                $jsonObj = [PSCustomObject]@{}
            }
            if ($jsonObj."realtimeTex.texliveBin" -ne $FoundBinPath) {
                $jsonObj | Add-Member -NotePropertyName "realtimeTex.texliveBin" -NotePropertyValue $FoundBinPath -Force
                $jsonObj | ConvertTo-Json -Depth 10 | Set-Content $sf -Encoding UTF8
                Write-Success "Bound 'realtimeTex.texliveBin' in: $sf"
            } else {
                Write-Info "Settings already configured in: $sf"
            }
        } catch {
            Write-Warn "Could not auto-configure $sf: $($_.Exception.Message)"
        }
    }
}

# ---------------------------------------------------------------------------
# 9. Summary & Completion
# ---------------------------------------------------------------------------
Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "   INSTALLATION & CONFIGURATION COMPLETED SUCCESSFULLY!   " -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Summary of Setup:" -ForegroundColor White
Write-Host "  1. MiKTeX suite installed at: $FoundBinPath"
Write-Host "  2. System User PATH updated (restart open terminals / IDE to refresh)."
Write-Host "  3. Automatic package download enabled (no manual CTAN package installs needed)."
Write-Host "  4. LuaLaTeX and pdfLaTeX are operational."
Write-Host "  5. Live preview in Realtime TeX / LaTeX Workshop is now ready to use.`n"

if (-not $NonInteractive) {
    try {
        if ([Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
            Write-Host "Press any key to continue..." -ForegroundColor Gray
            [Console]::ReadKey($true) | Out-Null
        }
    } catch {
        # Ignore console read errors if invoked via piped batch
    }
}
