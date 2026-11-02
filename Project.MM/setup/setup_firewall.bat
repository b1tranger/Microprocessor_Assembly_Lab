@echo off
:: ============================================================================
:: Automated Windows Firewall Configurator for Wokwi Gateway NAS (Port 9080)
:: Allows simultaneous access via Localhost, Ethernet LAN, & Mobile Hotspot
:: ============================================================================

TITLE Wokwi Gateway NAS - Windows Firewall Setup

:: 1. Check for Administrator Privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo [INFO] Administrative privileges required to configure Windows Firewall.
    echo [INFO] Requesting UAC elevation...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin_wokwigw.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin_wokwigw.vbs"
"%temp%\getadmin_wokwigw.vbs"
exit /B

:gotAdmin
if exist "%temp%\getadmin_wokwigw.vbs" ( del "%temp%\getadmin_wokwigw.vbs" )
pushd "%CD%"
CD /D "%~dp0"

echo ============================================================================
echo   Project.MM: Configuring Inbound Windows Firewall Rule for Port 9080
echo ============================================================================
echo.
echo Target Port      : 9080 (TCP)
echo Rule Display Name: "Wokwi Gateway NAS"
echo Network Profiles : Any (Domain, Private, Public)
echo Multi-Interface  : Ethernet LAN + Windows Mobile Hotspot Wi-Fi
echo.

:: 2. Execute PowerShell to configure firewall rule across all profiles
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ruleName = 'Wokwi Gateway NAS'; " ^
    "$existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue; " ^
    "if ($existing) { " ^
    "    Set-NetFirewallRule -DisplayName $ruleName -Direction Inbound -LocalPort 9080 -Protocol TCP -Profile Any -Action Allow -Enabled True; " ^
    "    Write-Host '[SUCCESS] Existing rule updated: Inbound TCP 9080 is enabled across all profiles!' -ForegroundColor Green; " ^
    "} else { " ^
    "    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -LocalPort 9080 -Protocol TCP -Profile Any -Action Allow; " ^
    "    Write-Host '[SUCCESS] New inbound rule created: Port 9080 is now open across all profiles!' -ForegroundColor Green; " ^
    "}"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================================================
    echo [STATUS] Port 9080 is now open on your workstation!
    echo.
    echo Next Steps:
    echo  1. Launch wokwigw.exe (Binds automatically to 0.0.0.0:9080):
    echo     .\wokwigw.exe --forward 9080:10.13.37.2:80
    echo.
    echo  2. Connect your client devices:
    echo     - Localhost (This PC) : http://localhost:9080/
    echo     - Mobile Hotspot      : http://192.168.137.1:9080/  (Phones/Tablets)
    echo     - Wired Ethernet LAN  : http://^<LAN_IP^>:9080/       (Lab desktop PCs)
    echo ============================================================================
) else (
    echo.
    echo [ERROR] Failed to configure Windows Firewall. Please verify PowerShell access.
)

echo.
pause

