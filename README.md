# wireguard-configuration-system

## Description
Wireguard Configuration System will help you create a wireguard vpn configuration for both the server and 'x' number of clients. Running the container will prompt you to enter the remote server IP address and the amount of roaming clients you would like to create configurations for. After the container has finished you will see the following in your current working directory

Current Working Directory:
- README.txt
- client
  - <remote_ip>p1.conf
  - <remote_ip>px.conf
- server
  - wg0.conf
  
Follow the instructions below for Server and Peer setup.

## Download and Running from Docker Hub
````
mkdir configurations
cd configurations
docker run --rm -it -v ${PWD}:/configurations rickjacobo/wireguard-configuration-system:latest
````

## Or, build you own Docker image locally and run
````
git clone https://github/rickjacobo/wireguard-configuration-system
cd wireguard-configuration-system
docker build -t local/wireguard-configuration-system .
docker run --rm -it -v ${PWD}:/configurations local/wireguard-configuration-system
````

## Server
### Server configuration for Ubuntu 20.04
Adapt configuration as needed for your server operating system

1. Install Wireguard Server
````
apt-get install wireguard -y
````

2. Move generated wg0.conf or write/paste the contents of wg0.conf to /etc/wireguard/wg0.conf

3. Start the wireguard server
````
wg-quick up wg0
````

4. Ensure your server is publicly accessible on port 51820/udp

## Peer(s)
1. Download [wireguard client](https://www.wireguard.com/install/)
   - [Windows](https://download.wireguard.com/windows-client/wireguard-installer.exe)
   - [macOS](https://itunes.apple.com/us/app/wireguard/id1451685025?ls=1&mt=12)
   - [iOS](https://itunes.apple.com/us/app/wireguard/id1441195209?ls=1&mt=8)
   - [Android](https://play.google.com/store/apps/details?id=com.wireguard.android)
2. Distribute peer configurations
3. Import peer configuration(s) into wireguard client(s) on a per client basis as needed
