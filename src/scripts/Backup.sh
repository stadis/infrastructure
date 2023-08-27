#!/bin/bash

DestFolder_WWW="/backups/ms/www"
#DestFolder_WWW_var="/root/backups/ms/www/var-www"
#DestFolder_WWW_apache2="/root/backups/ms/www/etc-apache2"
#DestFolder_WWW_letsencrypt="/root/backups/ms/www/etc-letsencrypt"
#DestFolder_Docker="/root/backups/ms/docker"
#DestFolder_RootHomeFolder="/root/backups/ms/root-home"
DestSSHInfo="u364842@u364842.your-storagebox.de"

while IFS== read -r key value; do
  printf -v "$key" %s "$value" && export "$key"
done <$HOME/infrastructure/src/resources/.env

# Main Server
## MySQL
/usr/bin/docker exec bookstack_db sh -c 'exec /usr/bin/mysqldump --all-databases --single-transaction --quick --lock-tables=false -u root -p$BOOKSTACK__MYSQL_ROOT_PASSWORD' > /tmp/sql-dump.sql
/usr/bin/rsync -e 'ssh -p23' -az /tmp/sql-dump.sql u364842@u364842.your-storagebox.de:/backups/ms/www/WWW-SQL-Dump.sql # u364842@u364842.your-storagebox.de:/backups/ms/www
# /usr/bin/rsync -e 'ssh -p23' -az /tmp/sql-dump.sql $DestSSHInfo:$DestFolder_WWW/WWW-SQL-Dump.sql
/usr/bin/rm /tmp/sql-dump.sql
# /usr/bin/docker exec -it <container> mysql -u root -p
# USE <database>
# show tables;

## /var/www, /etc/apache2, /etc/letsencrypt
/usr/bin/rsync -e 'ssh -p 1010' -azrd --delete /var/www/* $DestSSHInfo:$DestFolder_WWW_var/
/usr/bin/rsync -e 'ssh -p 1010' -azrd --delete /etc/apache2/* $DestSSHInfo:$DestFolder_WWW_apache2/
/usr/bin/rsync -e 'ssh -p 1010' -azrd --delete /etc/letsencrypt/* $DestSSHInfo:$DestFolder_WWW_letsencrypt/
## /dockerData
/usr/bin/rsync -e 'ssh -p 1010' -azrd --delete /dockerData/* $DestSSHInfo:$DestFolder_Docker/ #root@real.chse.dev:/root/backups/ms/docker
## /root
/usr/bin/rsync -e 'ssh -p 1010' -azrd --delete /root/* $DestSSHInfo:$DestFolder_RootHomeFolder/

/usr/bin/rsync --progress -e 'ssh -p23' --recursive <Lokales Verzeichnis> <Benutzername>@<Benutzername>.your-storagebox.de:<Ziel Verzeichnis>
