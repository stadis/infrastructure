#!/bin/bash

(/usr/bin/crontab -l ; echo "0 1 * * * /root/Scripts/Backup.sh") | /usr/bin/crontab -
