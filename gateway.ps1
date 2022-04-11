param (
        [parameter(mandatory=$true,position=1)]
        $PublicIp,
        [parameter(mandatory=$true,position=2)]
        $Peers
)
cd $PSScriptRoot

$ConfigurationType = "Gateway Router"
$Port = "51820"
$Description = $PublicIP.Replace(".","-")
$Endpoint = "$PublicIP" + ":" + "$Port"
$Site = Get-Random -Minimum 1 -Maximum 250
$Nic = ((ip r | Select-String -Pattern "default via") -split " " )[4]

# Create Configuration Directory
$ConfigurationDirectory = "$PsScriptRoot/configurations/$Description"
    if (Test-Path $ConfigurationDirectory) {
        # Do Nothing
    }
    else {
        mkdir -p $ConfigurationDirectory
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
Public Server IP Address: $PublicIP
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
PreUp = sysctl -w net.ipv4.ip_forward=1
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $NIC -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $NIC -j MASQUERADE

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
DNS = 8.8.8.8
PrivateKey = $WGPeerPrivate
ListenPort = $Port

[PEER]
PublicKey = $WGServerPublic
Endpoint = $Endpoint
AllowedIPs = 0.0.0.0/0

PersistentKeepalive = 0
"@

$PeerServerConfiguration = @"
[PEER]
PublicKey = $WGPeerPublic
AllowedIPs = 10.10.$Site.$Peer/32

"@

$WGSetup = @"
sudo apt-get install wireguard -y
sudo ufw allow 51820/udp
sudo ufw allow 22/tcp
sudo ufw disable
echo "y" | sudo ufw enable
cp $ConfigurationDirectory/server/$WGConf /etc/wireguard/wg0.conf
sudo systemctl enable wg-quick@wg0.service
sudo systemctl start wg-quick@wg0.service
sudo systemctl status wg-quick@wg0.service
"@

Write-Output $PeerConfiguration | Out-File $ConfigurationDirectory/client/$WGPeerConf -Force
Write-Output $PeerServerConfiguration | Out-File $ConfigurationDirectory/server/$WGConf -Append
Write-Output $WGSetup | Out-File $ConfigurationDirectory/server/WGSetup.sh -Force
}
