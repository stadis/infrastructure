#!/bin/bash

export $(grep -v '^#' ./resources/.env | xargs)
echo $MESSAGE
sleep 10
## Home Folder
/usr/bin/rsync -azrdu --delete -e 'ssh -p23' $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_ROOTHOMEFOLDER/ /root/ #-o StrictHostKeyChecking=no
