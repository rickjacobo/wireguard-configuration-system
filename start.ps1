rm -rf /configurations/*

$ReadHost = Read-Host "
1. Roaming Point to Point VPN (Mobile Wireguard Client to Server Configuration)
2. Gateway Configuration

Please enter a selection"
if ($ReadHost -eq "1") {
    pwsh roaming-point-to-point.ps1
}

if ($ReadHost -eq "1") {
    pwsh gateway.ps1
}

