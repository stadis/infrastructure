#!/bin/bash

# Check if we are running as sudo, if not, exit
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root. Maybe try 'sudo !!'"
    exit
fi

if [ -z "$1" ]; then
    echo "You need to specify arguments for this script."
    echo "bash mainserver.sh secrets # Allow script to run, after you have configured secrets and SSH private key."
    echo "bash mainserver.sh secrets sync # Sync data from backup server."
    exit
fi

echo $1
