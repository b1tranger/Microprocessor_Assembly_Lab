@echo off
chcp 65001 >nul
REM Automated Python Installer Launcher (Bypasses PowerShell ExecutionPolicy)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_python.ps1"
pause
