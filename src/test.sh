#!/bin/bash

export $(grep -v '^#' ./resources/.env | xargs)
echo $MESSAGE
echo /usr/bin/rsync -e 'ssh -p 23' -azrd --delete /etc/letsencrypt/* $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_WWW_LETSENCRYPT/
/usr/bin/rsync -e 'ssh -p 23' -azrd --delete /etc/letsencrypt/* $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_WWW_LETSENCRYPT/
