#!/bin/bash

export $(grep -v '^#' resources/.env | xargs)

# Sync data from backup server
DestSSHInfo="u364842@u364842.your-storagebox.de"
# /usr/bin/rsync -azrdu --delete -e 'ssh -p23 -o StrictHostKeyChecking=no' u364842@u364842.your-storagebox.de:backups/ms/www/WWW-SQL-Dump.sql /tmp/sql-dump.sql
/usr/bin/rsync -azrdu --delete -e 'ssh -p23 -o StrictHostKeyChecking=no' DestSSHInfo:backups/ms/www/WWW-SQL-Dump.sql /tmp/sql-dump.sql
/usr/bin/cat /tmp/sql-dump.sql | /usr/bin/docker exec -i bookstack_db /usr/bin/mysql -u root -p$BOOKSTACK__MYSQL_ROOT_PASSWORD
/usr/bin/rm /tmp/sql-dump.sql
## Home Folder
/usr/bin/rsync -azrdu --delete -e 'ssh -p23 -o StrictHostKeyChecking=no' DestSSHInfo:backups/ms/root-home/ /root/
## Docker Stuff
/usr/bin/mkdir -p /dockerData
/usr/bin/rsync -azrdu --delete -e 'ssh -p23 -o StrictHostKeyChecking=no' DestSSHInfo:backups/hs/docker/ /dockerData/
