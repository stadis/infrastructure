#!/bin/bash

export $(grep -v '^#' ./resources/.env | xargs)
echo $MESSAGE

/usr/bin/rsync --progress -e 'ssh -p23' -azrd --delete /etc/letsencrypt/* $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_WWW_LETSENCRYPT/
