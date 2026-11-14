@echo off
chcp 65001 >nul
title Refresh ESP32 Firmware Build
REM Firmware Compilation Launcher (Bypasses PowerShell ExecutionPolicy)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0refresh_firmware.ps1"
echo.
pause

