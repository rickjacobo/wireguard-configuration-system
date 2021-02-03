cd $PSScriptRoot
$ConfigurationType = "Roaming Point-to-Point"
$Public = (Read-Host "Enter Wireguard Server Public IP Address")
$Port = "51820"
$Description = $Public.Replace(".","-")
$Endpoint = "$Public" + ":" + "$Port"
$Peers = (Read-Host "How many peers will connect to the wireguard server (1-250)")
$Site = Get-Random -Minimum 1 -Maximum 250

# Create Configuration Directory
$ConfigurationDirectory = "/configurations/$Description"
    if (Test-Path $ConfigurationDirectory) {
        # Do Nothing
    }
    else {
        mkdir $ConfigurationDirectory
    }

    if (Test-Path $ConfigurationDirectory/server) {
        # Do Nothing
    }
    else {
        mkdir $ConfigurationDirectory/server
    }

    if (Test-Path $ConfigurationDirectory/client) {
        # Do Nothing
    }
    else {
        mkdir $ConfigurationDirectory/client
    }

# Add README to configurations directory
$Readme = @"
# README

## Server Configuration
Configuration Type: $ConfigurationType
Public Server IP Address: $Public
Public Endpoint: $Endpoint
Internal IP Server Address: 10.10.$Site.254 
Peers: $Peers

## Instructions
Check out the latest README.md at https://github/rickjacobo/wireguard-configuration-system
"@

Write-Output $Readme | Out-File $ConfigurationDirectory/README.txt -Force


# Server Configuration
$WGConf = "wg0.conf"
$WGServerPrivate = wg genkey
$WGServerPublic = $WGServerPrivate | wg pubkey

$ServerConfiguration = @"
[INTERFACE]
Address = 10.10.$Site.254
PrivateKey = $WGServerPrivate
ListenPort = $Port

"@

Write-Output $ServerConfiguration | Out-File $ConfigurationDirectory/server/$WGConf -Force


# Peer Configuration
for ($Peer=1; $Peer -le $Peers; $Peer++) {

$WGPeerPrivate = wg genkey
$WGPeerPublic = $WGPeerPrivate | wg pubkey
$WGPeerConf = "$Description" + "-" + "p" + "$Peer.conf"


$PeerConfiguration = @"
[INTERFACE]
Address = 10.10.$Site.$Peer
PrivateKey = $WGPeerPrivate
ListenPort = $Port

[PEER]
PublicKey = $WGServerPublic
Endpoint = $Endpoint
AllowedIPs = 10.10.$Site.254/32

PersistentKeepalive = 0
"@

$PeerServerConfiguration = @"
[PEER]
PublicKey = $WGPeerPublic
AllowedIPs = 10.10.$Site.$Peer/32

"@

Write-Output $PeerConfiguration | Out-File $ConfigurationDirectory/client/$WGPeerConf -Force
Write-Output $PeerServerConfiguration | Out-File $ConfigurationDirectory/server/$WGConf -Append

}
