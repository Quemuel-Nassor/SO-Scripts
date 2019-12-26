# Before you run this script in PowerShell in administrator mode, make sure your computer meets the requirements:

# Windows 7+ / Windows Server 2003+
# PowerShell v2+
# .NET Framework 4+ (the installation will attempt to install .NET 4.0 if you do not have it installed)

# Navigate to folder of this file, copy and paste the following comand in you PowerShell:
# Set-ExecutionPolicy Unrestricted -Scope Process -Force; .\Windows-Programs-Install

# Installing packages manager chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Installing programs
choco install vlc -y
choco install firefox -y
choco install googlechrome -y
choco install vscode -y
choco install 7zip -y
choco install discord -y
choco install git -y
choco install javaruntime
choco install jdk8
choco install driverbooster -y
choco install google-backup-and-sync -y
choco install virtualbox -y
choco install anydesk -y
choco install cpu-z -y
choco install hwmonitor -y
choco install ccleaner -y
choco install gimp -y
choco install steam -y
choco install utorrent -y
choco install formatfactory -y
choco install audacity -y
choco install imgburn -y
choco install crystaldiskinfo -y
choco install hdtune -y
choco install putty -y
choco install recuva -y
choco install wps-office-free -y
choco install netbeans -y