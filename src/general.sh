#!/bin/bash

# Check if we are running as sudo, if not, exit
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root. Maybe try 'sudo !!'"
    exit
fi

# Update the system
/usr/bin/apt update
/usr/bin/apt upgrade -y

# Install base packages
PACKAGES="
git
curl
wget"
/usr/bin/apt install -y "$(tr '\n' ' ' <<< "$PACKAGES")"

# Set default shell to zsh
/usr/bin/chsh -s "$(which zsh)"

# Disable MOTDs
/usr/bin/touch ~/.hushlogin

# Start fail2ban
/usr/bin/systemctl enable --now fail2ban

# Install oh-my-zsh
/usr/bin/sh -c "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install zsh plugins
## zsh-autosuggestions
/usr/bin/git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
