#!/bin/bash

# Check if we are running as sudo, if not, exit
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root. Maybe try 'sudo !!'"
    exit
fi

if [ -z "$1" ]; then
    echo "Please do not run this script directly."
    exit
fi

# Update the system
/usr/bin/apt update
/usr/bin/apt upgrade -y

# Install base packages
PACKAGES="
git
curl
wget
unzip
zip
htop
vim
sed
apt-transport-https
ca-certificates
software-properties-common
fail2ban
dos2unix
unattended-upgrades
gnupg
gnupg-agent
lsb-release
rsync
mosh
neofetch
zsh
dialog
molly-guard
"
/usr/bin/apt install -y $(tr '\n' ' ' <<< "$PACKAGES")

# Install SSH key
ssh-keygen -f ~stadisadm/.ssh/id_rsa -N ''
/usr/bin/chmod 600 ~stadisadm/.ssh/*
/usr/bin/chown stadisadm:stadisadm ~stadisadm/.ssh/*
/usr/bin/cat  ~stadisadm/.ssh/*.pub >> ~stadisadm/.ssh/authorized_keys
/usr/bin/chmod 644 ~stadisadm/.ssh/authorized_keys
# Upload keys (password required)
#ssh -o "StrictHostKeyChecking no" u364842@u364842.your-storagebox.de
/usr/bin/cat ~stadisadm/.ssh/id_rsa.pub | ssh -p23 u364842@u364842.your-storagebox.de -o "StrictHostKeyChecking no" install-ssh-key

# Lockdown SSH
#/usr/bin/sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
#/usr/bin/sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
#/usr/bin/sed -i 's/#PermitRootLogin no/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
#/usr/bin/sed -i 's/#UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
/usr/bin/systemctl restart sshd

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

# Install dotfiles
if [ -f ~/.zshrc ]; then /usr/bin/mv ~/.zshrc ~/.zshrc.bak; fi
/usr/bin/ln -s ~/infrastructure/src/dotfiles/zshrc ~/.zshrc
if [ -f ~/.vimrc ]; then /usr/bin/mv ~/.vimrc ~/.vimrc.bak; fi
/usr/bin/ln -s ~/infrastructure/src/dotfiles/vimrc ~/.vimrc
if [ -f ~/.gitconfig ]; then /usr/bin/mv ~/.gitconfig ~/.gitconfig.bak; fi
/usr/bin/ln -s ~/infrastructure/src/dotfiles/gitconfig ~/.gitconfig

# Setup Scripts
/usr/bin/mkdir -p ~/Scripts && /usr/bin/cp scripts/* ~/Scripts/

# Setup MOTD
/usr/bin/cp ./resources/motd.sh /etc/motd.sh
/usr/bin/chmod +x /etc/motd.sh

# Setup unattended upgrades
/usr/bin/cp ./resources/unattended-upgrades/* /etc/apt/apt.conf.d/

# sysctl tweaks
/usr/bin/cp ./resources/sysctl.conf /etc/sysctl.conf
/usr/sbin/sysctl -p
