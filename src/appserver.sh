#!/bin/bash

# Check if we are running as sudo, if not, exit
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root. Maybe try 'sudo !!'"
    exit
fi

if [ -z "$1" ]; then
    echo "You need to specify arguments for this script."
    echo "bash appserver.sh secrets_path # Allow script to run, after you have configured secrets"
    echo "bash appserver.sh secrets_path sync # Sync data from backup server."
    exit
fi

# Do everything in general.sh first
/usr/bin/bash general.sh secrets

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

# Move secrets
/usr/bin/mv $1 ./resources

# Add crontabs or check by sudo crontab -u root -e
(/usr/bin/crontab -l ; echo "0 1 * * * /root/Scripts/Backup.sh") | /usr/bin/crontab -
(/usr/bin/crontab -l ; echo "0 2 * * * docker image prune -a -f && docker volume prune -f && docker network prune -f") | /usr/bin/crontab -

# Snaps
/usr/bin/snap refresh
/usr/bin/snap install certbot --classic
/usr/bin/snap set certbot trust-plugin-with-root=ok

# Let's Encrypt Certificates
certbot certonly --nginx --agree-tos --preferred-challenges http -d tools.stadis.de,docs.stadis.de,vault.stadis.de,portainer-org.stadis.de -m marcel@scherbinek.de --redirect
# Update and Restart Nginx Reverse Proxy
/usr/bin/cp ./resources/default /etc/nginx/sites-available/default
/usr/bin/systemctl restart nginx

if [ "$2" = "sync" ]; then
    ## Set Environment Variables
    export $(grep -v '^#' ./resources/.env | xargs)
    echo $MESSAGE
    
    ## Home Folder
    /usr/bin/rsync -azrd --delete -e 'ssh -p23 -i ~stadisadm/.ssh/id_rsa -o StrictHostKeyChecking=no' $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_ROOTHOMEFOLDER/ /root
    ## Docker Stuff
    /usr/bin/mkdir -p ./resources/dockerData
    # /usr/bin/rsync -azrd --delete -e 'ssh -p23 -o StrictHostKeyChecking=no' u364842@u364842.your-storagebox.de:backups/ms/docker/ ./resources/dockerData
    /usr/bin/rsync -azrd --delete -e 'ssh -p23 -i ~stadisadm/.ssh/id_rsa -o StrictHostKeyChecking=no' $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_DOCKER/ ./resources/dockerData
fi

# Use docker-compose to initially start all the containers
cd ./resources || exit
/usr/bin/docker compose up -d
cd ../

if [ "$2" = "sync" ]; then
    echo "Wait period until containers initialized.."
    sleep 30
    ## Database 
    /usr/bin/rsync -azrd --delete -e 'ssh -p23 -i ~stadisadm/.ssh/id_rsa -o StrictHostKeyChecking=no' $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_WWW/WWW-SQL-Dump.sql /tmp/sql-dump.sql
    /usr/bin/cat /tmp/sql-dump.sql | /usr/bin/docker exec -i bookstack_db /usr/bin/mysql -u root -p$BOOKSTACK__MYSQL_ROOT_PASSWORD
    /usr/bin/rm /tmp/sql-dump.sql

    # Restart container
    cd ./resources || exit
    /usr/bin/docker compose restart
    cd ../
fi

echo
echo "Finished!"
echo

cd ~ || exit
