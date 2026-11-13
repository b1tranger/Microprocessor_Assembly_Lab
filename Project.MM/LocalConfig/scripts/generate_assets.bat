@echo off
setlocal
cd /d "%~dp0\.."

echo ==================================================
echo  Syncing Embedded Assets from data/ Directory
echo ==================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0generate_assets.ps1"
if %ERRORLEVEL% equ 0 (
    echo [SUCCESS] Assets synchronized into include\default_assets.h.
) else (
    echo [ERROR] Asset synchronization failed with code %ERRORLEVEL%.
)

