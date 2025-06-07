#!/bin/bash

# Set dark theme for user
sudo -u "$LOGNAME" dbus-launch gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'

# Set dock position to bottom
sudo -u "$LOGNAME" dbus-launch gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'

# Stop and disable snapd
systemctl stop snapd
systemctl disable snapd

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

# Add Microsoft repository
wget -q https://packages.microsoft.com/config/ubuntu/22.04/prod.list -O /tmp/microsoft-prod.list
mv /tmp/microsoft-prod.list /etc/apt/sources.list.d/microsoft-prod.list

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
apt install -y firefox microsoft-edge-stable code

# Configure flatpak and install additional apps
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub io.dbeaver.DBeaverCommunity com.microsoft.AzureStorageExplorer