#!/bin/bash

DestFolder_WWW="backups/ms/www"
DestFolder_WWW_letsencrypt="backups/ms/www/etc-letsencrypt"
DestFolder_Docker="backups/ms/docker"
DestFolder_RootHomeFolder="backups/ms/root-home"
DestSSHInfo="u364842@u364842.your-storagebox.de"

export $(grep -v '^#' /home/$SUDO_USER/infrastructure/src/resources/.env | xargs)

# sudo ssh -p23 u364842@u364842.your-storagebox.de
# cd backups/ms/www 
# ls -l
# -rw-r--r--  1 u364842  u364842  2574545 Aug 28 07:03 WWW-SQL-Dump.sql

# Org Server
## MySQL
/usr/bin/docker exec bookstack_db sh -c 'exec /usr/bin/mysqldump --all-databases --single-transaction --quick --lock-tables=false -u root -p$BOOKSTACK__MYSQL_ROOT_PASSWORD' > /tmp/sql-dump.sql
/usr/bin/rsync -e 'ssh -p23' -az /tmp/sql-dump.sql $DestSSHInfo:$DestFolder_WWW/WWW-SQL-Dump.sql
/usr/bin/rm /tmp/sql-dump.sql

## /etc/letsencrypt
/usr/bin/rsync -e 'ssh -p23' -azrd --delete /etc/letsencrypt/* $DestSSHInfo:$DestFolder_WWW_letsencrypt/
## /dockerData
/usr/bin/rsync -e 'ssh -p23' -azrd --delete /home/$SUDO_USER/infrastructure/src/resources/dockerData/* $DestSSHInfo:$DestFolder_Docker/
## /root
/usr/bin/rsync -e 'ssh -p23' -azrd --delete /root/* $DestSSHInfo:$DestFolder_RootHomeFolder/
