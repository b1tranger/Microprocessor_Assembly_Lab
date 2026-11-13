@echo off
REM 100% Offline Installer Launcher (Bypasses PowerShell ExecutionPolicy)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_offline.ps1"
pause
