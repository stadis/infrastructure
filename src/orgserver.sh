#!/bin/bash

# Check if we are running as sudo, if not, exit
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root. Maybe try 'sudo !!'"
    exit
fi

# Do everything in general.sh first
/usr/bin/bash general.sh

# Change SSH Port
/usr/bin/sed -i 's/#Port 22/Port 1000/g' /etc/ssh/sshd_config
/usr/bin/systemctl restart sshd

# Install docker
## INFO: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
/usr/bin/sudo /usr/bin/mkdir -p /etc/apt/keyrings
/usr/bin/curl -fsSL https://download.docker.com/linux/ubuntu/gpg | /usr/bin/sudo /usr/bin/gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | /usr/bin/sudo /usr/bin/tee /etc/apt/sources.list.d/docker.list > /dev/null
/usr/bin/sudo /usr/bin/apt-get update
/usr/bin/sudo /usr/bin/apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
/usr/bin/systemctl enable --now docker

# Install main server packages
PACKAGES="
nginx
snapd
software-properties-common
"
/usr/bin/apt install -y $(tr '\n' ' ' <<< "$PACKAGES")

# Add crontabs or check by sudo crontab -u root -e
(/usr/bin/crontab -l ; echo "0 1 * * * /root/Scripts/Backup.sh") | /usr/bin/crontab -
#(/usr/bin/crontab -l ; echo "0 2 * * * docker image prune -a -f && docker volume prune -f && docker network prune -f") | /usr/bin/crontab -

# Snaps
/usr/bin/snap refresh
/usr/bin/snap install certbot --classic
/usr/bin/snap set certbot trust-plugin-with-root=ok

# Let's Encrypt Certificates
certbot certonly --nginx --agree-tos --preferred-challenges http -d tools.stadis.de,docs.stadis.de,vault.stadis.de,pastebin.stadis.de,portainer-org.stadis.de -m marcel@scherbinek.de --redirect
# Update Nginx Reverse Proxy
/usr/bin/cp ./resources/default /etc/nginx/sites-available/default
/usr/bin/systemctl restart nginx

# Use docker-compose to start all the containers
cd resources || exit

echo
echo "Almost there!"
echo "Initial steps:"
echo "- Setup Docker container .env & dockerData configs."
echo "- Run  docker compose up -d          (should be root user when running this)"
echo "Sync steps (for restore from backup):"
echo "- Setup Docker container .env & dockerData configs."
echo "- Run docker compose up -d          (should be root user when running this)"
echo "- Run bash orgserver-sync.sh        (should be root user when running this)"
echo
