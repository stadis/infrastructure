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
/usr/bin/chown $USER:$USER ~stadisadm/.ssh/*
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
