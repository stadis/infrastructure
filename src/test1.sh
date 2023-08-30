#!/bin/bash

## Set Environment Variables
export $(grep -v '^#' ./resources/.env | xargs)
echo $MESSAGE

/usr/bin/rsync -azrd --delete -e 'ssh -p23 -i ~stadisadm/.ssh/id_rsa' $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_ROOTHOMEFOLDER/ /root
## Docker Stuff
/usr/bin/mkdir -p ./resources/dockerData
# /usr/bin/rsync -azrd --delete -e 'ssh -p23 -o StrictHostKeyChecking=no' u364842@u364842.your-storagebox.de:backups/ms/docker/ ./resources/dockerData
/usr/bin/rsync -azrd --delete -e 'ssh -p23 -i ~stadisadm/.ssh/id_rsa' $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_DOCKER/ ./resources/dockerData
