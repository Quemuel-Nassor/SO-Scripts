#!/bin/bash

# Stop and disable snapd
systemctl stop snapd
systemctl stop snapd.socket
systemctl disable snapd
systemctl disable snapd.socket

# Disable network waiter
systemctl disable NetworkManager-wait-online.service

# Disable boot animation
systemctl mask plymouth-quit-wait.service

# Remove all snap packages
for pkg in $(snap list | awk 'NR > 1 {print $1}'); do
    snap remove "$pkg"
done

# Remove unused packages
apt purge -y snapd yelp evince gnome-nettool gnome-power-statistics gnome-system-monitor software-properties-gtk update-manager

# Remove snap-related folders
rm -rf /root/snap /snap /var/snap /var/lib/snapd /home/*/snap

# Prevent snapd from being reinstalled
apt-mark hold snapd

# Install required dependencies
apt update
apt install --no-install-recommends -y software-properties-common gpg wget

########### Configure Private repositories ###########

# Add Firefox repository
add-apt-repository -y ppa:mozillateam/ppa

# Add Microsoft .NET backports for Ubuntu 22.04 (.NET 9)
add-apt-repository -y ppa:dotnet/backports

########### Configure Microsoft respositories ###########

# Get OS version info which adds the $ID and $VERSION_ID variables
source /etc/os-release

# Download Microsoft signing key and repository
wget https://packages.microsoft.com/config/$ID/$VERSION_ID/packages-microsoft-prod.deb -O packages-microsoft-prod.deb

# Install Microsoft signing key and repository
dpkg -i packages-microsoft-prod.deb

# Clean up
rm packages-microsoft-prod.deb

# Microsoft key can be on those places
#/etc/apt/trusted.gpg.d/
#/usr/share/keyrings/

# Add VsCode repository
cat <<EOF | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/repos/code stable main
EOF

# Add Edge repository
cat <<EOF | sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null
deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/repos/edge stable main
EOF

########### Configure APT preferences ###########

# Improve APT download performance
cat <<EOF | sudo tee /etc/apt/apt.conf.d/99parallel > /dev/null
Acquire::Queue-Mode "access";
Acquire::Retries "3";
Acquire::http::Dl-Limit "0";
Acquire::http::Pipeline-Depth "5";
EOF

# Configure APT to prefer packages from the Mozilla Team PPA instead of using Snap packages
cat <<EOL | sudo tee /etc/apt/preferences.d/mozilla-firefox > /dev/null
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOL

########### Install packages ###########

# Update APT and install apps
apt update
apt install --no-install-recommends -y flatpak gnome-software gnome-software-plugin-flatpak libreoffice-writer libreoffice-calc gimp gimp-data-extras ghostscript libwmf-bin git nodejs htop npm dotnet-sdk-9.0 dotnet-sdk-8.0
apt install -y firefox timeshift microsoft-edge-stable code

# Configure flatpak and install additional apps
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub io.dbeaver.DBeaverCommunity com.microsoft.AzureStorageExplorer

########### Package cleanup ###########

apt autoremove --purge -y
apt clean

########### Disable MSBUILD node reuse ###########

cat <<EOL >> ~/.bashrc
export MSBUILDDISABLENODEREUSE=1
EOL

source ~/.bashrc
