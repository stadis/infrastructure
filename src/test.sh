#!/bin/bash

export $(grep -v '^#' ./resources/.env | xargs)
echo $MESSAGE

/usr/bin/rsync -azrd --delete -e 'ssh -p23' $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_ROOTHOMEFOLDER/ /root
