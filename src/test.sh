#!/bin/bash

export $(grep -v '^#' ./resources/.env | xargs)
echo $MESSAGE
sleep 10
## Home Folder
/usr/bin/rsync -azrdu --delete -e 'ssh -p23 -o StrictHostKeyChecking=no' $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_ROOTHOMEFOLDER/ /root/
