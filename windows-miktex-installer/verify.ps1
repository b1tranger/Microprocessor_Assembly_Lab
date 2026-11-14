<#
.SYNOPSIS
    Verification & Health Check Script for MiKTeX, LuaLaTeX, and Editor Bridges.
.DESCRIPTION
    Checks whether LaTeX binaries are on PATH, tests LuaLaTeX compilation on
    a minimal test document, verifies on-the-fly package fetching, and inspects
    rtex (Realtime TeX) integration.
.PARAMETER SkipPause
    Skips the interactive "Press any key to exit" pause.
#>

[CmdletBinding()]
param(
    [switch]$SkipPause
)

$ErrorActionPreference = "Continue"

# ---------------------------------------------------------------------------
# 0. Reload Environment PATH from Registry and Known Candidate Paths
# ---------------------------------------------------------------------------
$UserPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
$MachinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
$CandidatePaths = @(
    (Join-Path $env:LOCALAPPDATA "Programs\MiKTeX\miktex\bin\x64"),
    (Join-Path $env:ProgramFiles "MiKTeX\miktex\bin\x64"),
    (Join-Path ${env:ProgramFiles(x86)} "MiKTeX\miktex\bin\x64")
)

$allPathEntries = @()
foreach ($p in $CandidatePaths) {
    if (Test-Path $p) { $allPathEntries += $p }
}
if ($MachinePath) { $allPathEntries += ($MachinePath -split ';') }
if ($UserPath) { $allPathEntries += ($UserPath -split ';') }
if ($env:PATH) { $allPathEntries += ($env:PATH -split ';') }

$validUniquePaths = $allPathEntries | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique
$env:PATH = $validUniquePaths -join ";"

function Write-Check {
    param([string]$Title, [bool]$Passed, [string]$Details = "")
    if ($Passed) {
        Write-Host " [PASS] " -ForegroundColor Green -NoNewline
        Write-Host "$Title" -ForegroundColor White -NoNewline
        if ($Details) { Write-Host " ($Details)" -ForegroundColor Gray } else { Write-Host "" }
    } else {
        Write-Host " [FAIL] " -ForegroundColor Red -NoNewline
        Write-Host "$Title" -ForegroundColor Yellow -NoNewline
        if ($Details) { Write-Host " - $Details" -ForegroundColor DarkYellow } else { Write-Host "" }
    }
}

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "      MiKTeX & LuaLaTeX Environment Diagnostic Check       " -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Binary availability
$luaCmd = Get-Command lualatex.exe -ErrorAction SilentlyContinue
$pdfCmd = Get-Command pdflatex.exe -ErrorAction SilentlyContinue
$xeCmd  = Get-Command xelatex.exe  -ErrorAction SilentlyContinue
$initCmd = Get-Command initexmf.exe -ErrorAction SilentlyContinue

Write-Check "LuaLaTeX Binary" ($null -ne $luaCmd) $(if ($luaCmd) { $luaCmd.Source } else { "Not found on PATH" })
Write-Check "pdfLaTeX Binary" ($null -ne $pdfCmd) $(if ($pdfCmd) { $pdfCmd.Source } else { "Not found on PATH" })
Write-Check "XeLaTeX Binary"  ($null -ne $xeCmd)  $(if ($xeCmd)  { $xeCmd.Source }  else { "Not found on PATH" })
Write-Check "MiKTeX Maintenance Utility (initexmf)" ($null -ne $initCmd) $(if ($initCmd) { $initCmd.Source } else { "Not found on PATH" })

# 2. Check Package Auto-Install Configuration
if ($initCmd) {
    try {
        $val = & $initCmd.Source --show-config-value "[MPM]AutoInstall" 2>&1
        $isAuto = ($val -match "1|yes")
        Write-Check "On-the-fly package download enabled" $isAuto "Value: $val"
    } catch {
        Write-Check "On-the-fly package download check" $false "Failed to query initexmf"
    }
}

# 3. Test LuaLaTeX End-to-End Compilation
Write-Host "`n--> Testing LuaLaTeX Document Compilation..." -ForegroundColor Cyan

$testDir = Join-Path $env:TEMP "miktex_verify_test"
if (Test-Path $testDir) { Remove-Item $testDir -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $testDir | Out-Null

$testTex = Join-Path $testDir "test.tex"
@"
\documentclass{article}
\usepackage{amsmath}
\begin{document}
Hello from LuaLaTeX!
Equation: $E = mc^2$
\end{document}
"@ | Out-File -FilePath $testTex -Encoding ascii

$compileSuccess = $false
if ($luaCmd) {
    Push-Location $testDir
    try {
        $output = & $luaCmd.Source --interaction=nonstopmode test.tex 2>&1
        $pdfOut = Join-Path $testDir "test.pdf"
        if (Test-Path $pdfOut) {
            $compileSuccess = $true
        }
    } finally {
        Pop-Location
    }
}

Write-Check "LuaLaTeX Sample Compilation (test.tex -> test.pdf)" $compileSuccess $(if ($compileSuccess) { "PDF generated successfully" } else { "Compilation failed or binary missing" })

# Clean up test files
Remove-Item $testDir -Recurse -Force -ErrorAction SilentlyContinue

# 4. Check Realtime TeX (rtex) Doctor
Write-Host "`n--> Testing Realtime TeX (rtex) Engine..." -ForegroundColor Cyan
$PossibleRtexPaths = @(
    (Join-Path $env:APPDATA "Antigravity IDE\User\globalStorage\henryxiaoyang.realtime-tex\rtex-release\v0.0.7\bin\rtex.exe"),
    (Join-Path $env:APPDATA "Code\User\globalStorage\henryxiaoyang.realtime-tex\rtex-release\v0.0.7\bin\rtex.exe")
)

$rtexBin = $PossibleRtexPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($rtexBin) {
    try {
        $doc = & $rtexBin doctor 2>&1
        $rtexPassed = ($doc -match "lualatex:\s+ok" -or -not ($doc -match "missing"))
        Write-Check "rtex doctor status" $rtexPassed "Engine at: $rtexBin"
        if (-not $rtexPassed) {
            $doc | ForEach-Object { Write-Host "     $_" -ForegroundColor DarkGray }
        }
    } catch {
        Write-Check "rtex doctor execution" $false $_.Exception.Message
    }
} else {
    Write-Host " [INFO] rtex binary not found in standard VS Code/Antigravity storage locations." -ForegroundColor Gray
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
if ($compileSuccess) {
    Write-Host " System is ready for LaTeX authoring and real-time preview!" -ForegroundColor Green
} else {
    Write-Host " Setup requires action. Run install.bat to configure MiKTeX." -ForegroundColor Yellow
}
Write-Host "==========================================================`n" -ForegroundColor Cyan

if (-not $SkipPause) {
    try {
        if ([Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
            Write-Host "Press any key to exit..." -ForegroundColor Gray
            [Console]::ReadKey($true) | Out-Null
        }
    } catch {
        # Ignore console read errors if invoked via piped batch
    }
}
