@echo off
setlocal
title MiKTeX and LuaLaTeX Verification Tool

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0verify.ps1" %*
set SCRIPT_EXIT=%errorlevel%

echo.
pause
exit /b %SCRIPT_EXIT%
