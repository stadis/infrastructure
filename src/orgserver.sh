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

# TODO cp repo to  /etc/nginx/sites-available/default
#/usr/bin/cp ./resources/secrets/*.txt /etc/nginx/sites-available/default

# Add crontabs
#(/usr/bin/crontab -l ; echo "*/15 * * * * /root/ddns.sh") | /usr/bin/crontab -
#(/usr/bin/crontab -l ; echo "0 0 * * * certbot renew --dns-cloudflare --dns-cloudflare-credentials /root/CF-certbot.txt") | /usr/bin/crontab -
#(/usr/bin/crontab -l ; echo "0 1 * * * /root/Scripts/Backup/Backup.sh") | /usr/bin/crontab -
#(/usr/bin/crontab -l ; echo "0 2 * * * docker image prune -a -f && docker volume prune -f && docker network prune -f") | /usr/bin/crontab -
#(/usr/bin/crontab -l ; echo "0 * * * * curl --silent https://missionpark.net?es=cron&guid=edaiqo-pgoemj-cenpat-cbgkjr-fomgjy > /dev/null 2>&1") | /usr/bin/crontab -

# Snaps
/usr/bin/snap refresh
/usr/bin/snap install certbot --classic
/usr/bin/snap set certbot trust-plugin-with-root=ok
#/usr/bin/snap install certbot-dns-cloudflare
#/usr/bin/snap connect certbot:plugin certbot-dns-cloudflare

# Let's Encrypt Certificates
certbot run -n certonly --nginx --agree-tos -d tools.stadis.de,docs.stadis.de -m marcel@scherbinek.de --redirect

if [ "$1" = "sync" ]; then
    # Sync data from backup server
    backupIP="dns_or_ip"
    /usr/bin/rsync -azrdu --delete -e 'ssh -p1010 -o StrictHostKeyChecking=no' root@$backupIP:/root/backups/www/var-www/ /var/www/
    /usr/bin/chown -R www-data:www-data /var/www/
    /usr/bin/rsync -azrdu --delete -e 'ssh -p1010 -o StrictHostKeyChecking=no' root@$backupIP:/root/backups/www/etc-apache2/ /etc/apache2/
    /usr/bin/rsync -azrdu --delete -e 'ssh -p1010 -o StrictHostKeyChecking=no' root@$backupIP:/root/backups/www/etc-letsencrypt/ /etc/letsencrypt/
    /usr/bin/systemctl restart apache2
    ## Home Folder
    /usr/bin/rsync -azrdu --delete -e 'ssh -p1010 -o StrictHostKeyChecking=no' root@$backupIP:/root/backups/hs/root-home/ /root/
    ## Docker Stuff
    /usr/bin/mkdir -p /dockerData
    /usr/bin/rsync -azrdu --delete -e 'ssh -p1010 -o StrictHostKeyChecking=no' root@$backupIP:/root/backups/hs/docker/ /dockerData/
fi

# Use docker-compose to start all the containers
cd ./resources || exit

echo
echo "Almost there!"
echo "- Setup Docker container secrets"
echo "- Run /usr/bin/docker compose up -d (should be root user when running this)"
echo
