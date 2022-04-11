FROM mcr.microsoft.com/powershell:ubuntu-20.04
RUN apt-get update && apt-get install wireguard -y
RUN apt-get clean
RUN mkdir /configurations
RUN mkdir /wireguard
RUN mkdir /wireguard/configurations
WORKDIR /wireguard
COPY roaming-point-to-point.ps1 /wireguard
COPY start.ps1 /wireguard
CMD pwsh start.ps1
