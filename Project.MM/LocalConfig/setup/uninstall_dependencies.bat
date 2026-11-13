@echo off
chcp 65001 >nul
:: ============================================================================
:: Automated Uninstaller Launcher for ESP32 NAS Setup (Reverts Firewall, Env, Binaries)
:: ============================================================================

TITLE ESP32 NAS Setup - Automated Uninstaller

:: Check for Administrator Privileges (needed for Windows Firewall rule removal)
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo [INFO] Administrative privileges required to revert Windows Firewall rules.
    echo [INFO] Requesting UAC elevation...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin_uninstaller.vbs"
echo UAC.ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\getadmin_uninstaller.vbs"
"%temp%\getadmin_uninstaller.vbs"
exit /B

:gotAdmin
if exist "%temp%\getadmin_uninstaller.vbs" ( del "%temp%\getadmin_uninstaller.vbs" )
pushd "%CD%"
CD /D "%~dp0"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall_dependencies.ps1" %*

echo.
pause

