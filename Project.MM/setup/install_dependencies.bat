@echo off
REM Automated Dependency Installer Launcher (Bypasses PowerShell ExecutionPolicy)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_dependencies.ps1"
pause
