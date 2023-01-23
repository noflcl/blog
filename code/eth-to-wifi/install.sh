#!/usr/bin/bash
#
# Install packages and start eth0 to wlan0

echo -e "\n*** Setup eth to wifi router ***\n"

echo -e "Installing wifi router dependencies..."
sudo apt update && sudo apt -y upgrade
sudo apt -y install dnsmasq hostapd

sudo systemctl unmask hostapd
sudo systemctl enable hostapd

echo -e "\nSuccessfully completed.\n"

