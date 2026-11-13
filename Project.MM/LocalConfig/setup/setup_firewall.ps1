<#
.SYNOPSIS
    Automated Windows Firewall Configurator for Wokwi Gateway NAS (Port 9080).
.DESCRIPTION
    Opens inbound TCP Port 9080 across all network profiles (Domain, Private, Public)
    to enable multi-interface connections from external devices (Ethernet & Mobile Hotspot).
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Check for Administrator Privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[INFO] Administrative privileges required to configure Windows Firewall." -ForegroundColor Yellow
    Write-Host "[INFO] Requesting UAC elevation..." -ForegroundColor Cyan
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "==================================================" -ForegroundColor Cyan
echo " Configuring Windows Firewall for Wokwi Gateway "
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Target Port      : 9080 (TCP)" -ForegroundColor Gray
Write-Host "Rule Display Name: 'Wokwi Gateway NAS'" -ForegroundColor Gray
Write-Host "Network Profiles : Any (Domain, Private, Public)" -ForegroundColor Gray
Write-Host "Multi-Interface  : Ethernet LAN + Mobile Hotspot" -ForegroundColor Gray
Write-Host ""

$ruleName = "Wokwi Gateway NAS"
$existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

try {
    if ($existing) {
        Set-NetFirewallRule -DisplayName $ruleName -Direction Inbound -LocalPort 9080 -Protocol TCP -Profile Any -Action Allow -Enabled True -ErrorAction Stop
        Write-Host "[SUCCESS] Existing firewall rule updated: TCP 9080 is enabled across all profiles!" -ForegroundColor Green
    } else {
        New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -LocalPort 9080 -Protocol TCP -Profile Any -Action Allow -ErrorAction Stop | Out-Null
        Write-Host "[SUCCESS] Port 9080 is now open across all profiles!" -ForegroundColor Green
    }

    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host " Port 9080 is now open on your workstation! " -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "`nNext Steps:" -ForegroundColor White
    Write-Host " 1. Launch wokwigw.exe: .\wokwigw.exe --forward 9080:10.13.37.2:80" -ForegroundColor Yellow
    Write-Host " 2. Connect client devices:" -ForegroundColor White
    Write-Host "    - Localhost: http://localhost:9080/" -ForegroundColor Cyan
    Write-Host "    - Hotspot  : http://192.168.137.1:9080/ (Phones/Tablets)" -ForegroundColor Cyan
    Write-Host "    - LAN Switch: http://<LAN_IP>:9080/ (Lab PCs)`n" -ForegroundColor Cyan
} catch {
    Write-Host "[ERROR] Failed to configure Windows Firewall: $_" -ForegroundColor Red
}

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

