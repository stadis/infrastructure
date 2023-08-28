#!/bin/bash

DestFolder_WWW="/backups/ms/www"
#DestFolder_WWW_letsencrypt="/root/backups/ms/www/etc-letsencrypt"
#DestFolder_Docker="/root/backups/ms/docker"
#DestFolder_RootHomeFolder="/root/backups/ms/root-home"
DestSSHInfo="u364842@u364842.your-storagebox.de"

#while IFS== read -r key value; do
#  printf -v "$key" %s "$value" && export "$key"
#done <$HOME/infrastructure/src/resources/.env
export $(grep -v '^#'  $HOME/infrastructure/src/resources/.env | xargs)

# Main Server
## MySQL
/usr/bin/docker exec bookstack_db sh -c 'exec /usr/bin/mysqldump --all-databases --single-transaction --quick --lock-tables=false -u root -p$BOOKSTACK__MYSQL_ROOT_PASSWORD' > /tmp/sql-dump.sql

/usr/bin/rsync -e 'ssh -p23 u364842@u364842.your-storagebox.de' -az /tmp/sql-dump.sql /backups/ms/www/WWW-SQL-Dump.sql
# /usr/bin/rsync -e 'ssh -p23 $DestSSHInfo' -az /tmp/sql-dump.sql $DestFolder_WWW/WWW-SQL-Dump.sql

#/usr/bin/rm /tmp/sql-dump.sql

## /var/www, /etc/apache2, /etc/letsencrypt
#/usr/bin/rsync -e 'ssh -p 1010' -azrd --delete /etc/letsencrypt/* $DestSSHInfo:$DestFolder_WWW_letsencrypt/
## /dockerData
#/usr/bin/rsync -e 'ssh -p 1010' -azrd --delete /dockerData/* $DestSSHInfo:$DestFolder_Docker/ 
## /root
#/usr/bin/rsync -e 'ssh -p 1010' -azrd --delete /root/* $DestSSHInfo:$DestFolder_RootHomeFolder/
