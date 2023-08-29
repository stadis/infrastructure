#!/bin/bash

DestFolder_WWW="backups/ms/www"
DestFolder_WWW_letsencrypt="backups/ms/www/etc-letsencrypt"
DestFolder_Docker="backups/ms/docker"
DestFolder_RootHomeFolder="backups/ms/root-home"
DestSSHInfo="u364842@u364842.your-storagebox.de"

export $(grep -v '^#' resources/.env | xargs)

# Sync data from backup server
DestSSHInfo="u364842@u364842.your-storagebox.de"
# /usr/bin/rsync -azrdu --delete -e 'ssh -p23 -o StrictHostKeyChecking=no' u364842@u364842.your-storagebox.de:backups/ms/www/WWW-SQL-Dump.sql /tmp/sql-dump.sql
/usr/bin/rsync -azrdu --delete -e 'ssh -p23 -o StrictHostKeyChecking=no' $DestSSHInfo:$DestFolder_WWW/WWW-SQL-Dump.sql /tmp/sql-dump.sql
/usr/bin/cat /tmp/sql-dump.sql | /usr/bin/docker exec -i bookstack_db /usr/bin/mysql -u root -p$BOOKSTACK__MYSQL_ROOT_PASSWORD
/usr/bin/rm /tmp/sql-dump.sql
## Home Folder
/usr/bin/rsync -azrdu --delete -e 'ssh -p23 -o StrictHostKeyChecking=no' $DestSSHInfo:$DestFolder_RootHomeFolder/ /root/
## Docker Stuff
/usr/bin/mkdir -p /dockerData
/usr/bin/rsync -azrdu --delete -e 'ssh -p23 -o StrictHostKeyChecking=no' $DestSSHInfo:$DestFolder_Docker/ /dockerData/
