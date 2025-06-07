#!/bin/bash

# Stop and disable snapd
systemctl stop snapd
systemctl stop snapd.socket
systemctl disable snapd
systemctl disable snapd.socket

# Remove all snap packages
for pkg in $(snap list | awk 'NR > 1 {print $1}'); do
    snap remove "$pkg"
done

# Remove unused packages
apt purge -y snapd yelp evince gnome-nettool gnome-power-statistics gnome-system-monitor software-properties-gtk update-manager
apt autoremove --purge -y

# Remove snap-related folders
rm -rf /root/snap /snap /var/snap /var/lib/snapd /home/*/snap

# Prevent snapd from being reinstalled
apt-mark hold snapd

# Add Firefox repository
add-apt-repository -y ppa:mozillateam/ppa

# Configure APT to prefer packages from the Mozilla Team PPA instead of using Snap packages
cat <<EOL | sudo tee /etc/apt/preferences.d/mozilla-firefox > /dev/null
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOL

# Get OS version info which adds the $ID and $VERSION_ID variables
source /etc/os-release

# Download the Microsoft keys
sudo apt-get install -y gpg wget
wget https://packages.microsoft.com/keys/microsoft.asc
cat microsoft.asc | gpg --dearmor -o microsoft.asc.gpg

# Add the Microsoft repository to the system's sources list
wget https://packages.microsoft.com/config/$ID/$VERSION_ID/prod.list
sudo mv prod.list /etc/apt/sources.list.d/microsoft-prod.list

# Move the key to the appropriate place
sudo mv microsoft.asc.gpg $(cat /etc/apt/sources.list.d/microsoft-prod.list | grep -oP "(?<=signed-by=).*(?=\])")

# Improve APT download performance
cat <<EOF | sudo tee /etc/apt/apt.conf.d/99parallel > /dev/null
Acquire::Queue-Mode "access";
Acquire::Retries "3";
Acquire::http::Dl-Limit "0";
Acquire::http::Pipeline-Depth "5";
EOF

# Update APT and install apps
apt update
apt install --no-install-recommends -y flatpak gnome-software gnome-software-plugin-flatpak libreoffice-writer libreoffice-calc gimp gimp-data-extras ghostscript libwmf-bin git nodejs dotnet-sdk-8.0 dotnet-sdk-9.0
apt install -y firefox timeshift microsoft-edge-stable code

# Configure flatpak and install additional apps
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub io.dbeaver.DBeaverCommunity com.microsoft.AzureStorageExplorer
