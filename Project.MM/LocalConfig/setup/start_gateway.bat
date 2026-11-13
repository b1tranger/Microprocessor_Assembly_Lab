@echo off
REM Wokwi IoT Gateway Launcher (Bypasses PowerShell ExecutionPolicy)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0start_gateway.ps1"
pause
