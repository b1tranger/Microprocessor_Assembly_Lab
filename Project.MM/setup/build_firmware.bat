@echo off
REM Firmware Compilation Launcher (Bypasses PowerShell ExecutionPolicy)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_firmware.ps1"
pause
