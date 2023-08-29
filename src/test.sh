#!/bin/bash

export $(grep -v '^#' ./resources/.env | xargs)
echo $MESSAGE

/usr/bin/rsync -e --rsh='/usr/bin/sshpass -p $RSYNC_PASSWORD ssh -p 23' -azrd --delete /etc/letsencrypt/* $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_WWW_LETSENCRYPT/
