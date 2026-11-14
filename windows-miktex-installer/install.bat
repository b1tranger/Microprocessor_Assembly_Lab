@echo off
setlocal enabledelayedexpansion
title MiKTeX and LuaLaTeX One-Click Windows Installer

echo ==========================================================
echo    MiKTeX & LuaLaTeX One-Click Windows Automated Setup
echo ==========================================================
echo.

:: Check for administrative rights (informative only)
net session >nul 2>&1
if %errorlevel% == 0 (
    echo [INFO] Running with Administrator privileges.
) else (
    echo [INFO] Running in User Mode (Administrator not required for per-user setup).
)

echo.
echo Starting MiKTeX automated installation...
echo Please do not close this window until setup completes.
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
set SCRIPT_EXIT=%errorlevel%

echo.
if %SCRIPT_EXIT% neq 0 (
    echo ========================================================
    echo [ERROR] The installation script encountered an error (Exit Code: %SCRIPT_EXIT%).
    echo ========================================================
) else (
    echo ========================================================
    echo [SUCCESS] MiKTeX setup and verification finished successfully!
    echo ========================================================
)

echo.
pause
exit /b %SCRIPT_EXIT%
