@echo off
REM Offline Bundle Exporter Launcher (Bypasses PowerShell ExecutionPolicy)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0export_offline_bundle.ps1"
pause
