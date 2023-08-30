#!/bin/bash

# Set Environment Variables
export $(grep -v '^#' ~stadisadm/infrastructure/src/resources/.env | xargs) # SUDO_USER | USER

# grep Backup.sh /var/log/cron
# grep Backup.sh /var/log/syslog
# sudo ssh -p23 u364842@u364842.your-storagebox.de
# cd backups/ms/www 
# ls -l
# -rw-r--r--  1 u364842  u364842  2574545 Aug 28 07:03 WWW-SQL-Dump.sql

# RSYNC
# -e                          environment to be executed (rsync -e 'ssh ...')
# -a, --archive               archive mode;
# -z, --compress              compress file data during the transfer
# -r, --recursive             recurse into directories
# -d, --dirs                  transfer directories without recursing
# --delete                    delete extraneous files from the receiving side (ones that aren't on the sending side)

# Org Server
## MySQL
/usr/bin/docker exec bookstack_db sh -c 'exec /usr/bin/mysqldump --all-databases --single-transaction --quick --lock-tables=false -u root -p$BOOKSTACK__MYSQL_ROOT_PASSWORD' > /tmp/sql-dump.sql
/usr/bin/rsync -e 'ssh -p23 -i ~stadisadm/.ssh/id_rsa' -az /tmp/sql-dump.sql $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_WWW/WWW-SQL-Dump.sql
/usr/bin/rm /tmp/sql-dump.sql

# Stop running Container
/usr/bin/docker stop $(/usr/bin/docker ps -a -q)
sleep 15
## /dockerData
/usr/bin/rsync -e 'ssh -p23 -i ~stadisadm/.ssh/id_rsa' -azrd --delete ~stadisadm/infrastructure/src/resources/dockerData/* $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_DOCKER/
sleep 5
# Start all stopped Container
/usr/bin/docker restart $(/usr/bin/docker ps -a -q)
## /etc/letsencrypt
/usr/bin/rsync -e 'ssh -p23 -i ~stadisadm/.ssh/id_rsa' -azrd --delete /etc/letsencrypt/* $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_WWW_LETSENCRYPT/
## /root
/usr/bin/rsync -e 'ssh -p23 -i ~stadisadm/.ssh/id_rsa' -azrd --delete /root/* $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_ROOTHOMEFOLDER/
