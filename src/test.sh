#!/bin/bash

    ## Set Environment Variables
export $(grep -v '^#' ./resources/.env | xargs)
echo $MESSAGE
    
/usr/bin/rsync -azrdu --delete -e 'ssh -p23 -o StrictHostKeyChecking=no' $RSYNC__DESTSSHINFO:$RSYNC__DESTFOLDER_DOCKER/ /dockerData/
