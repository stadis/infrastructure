#!/bin/bash

export $(grep -v '^#' ./resources/.env | xargs)
echo $MESSAGE

/usr/bin/rsync --progress -e '/usr/bin/sshpass -p $RSYNC_PASSWORD ssh -p23 $RSYNC__DESTSSHINFO' -azrd --delete /etc/letsencrypt/* $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_WWW_LETSENCRYPT/
