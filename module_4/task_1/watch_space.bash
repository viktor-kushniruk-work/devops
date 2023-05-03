#!/usr/bin/env bash

# Set up the email address to send alerts to.
# This is the only thing you need to change.
# takes an optional argument for time to sleep between checks
alertaddress="vkushniruk1@gmail.com"
freespacethreshold=1
if [ -s "$1" ]; then
    sleepvalue=$1
else
    sleepvalue=60
fi
warning='\033[1;33m'
success='\033[0;32m'
error='\033[0;31m'

read -p "Enter the email address to send alerts to: [$alertaddress]"
read -p "Enter the free space threshold in GB: [$freespacethreshold]"


echo -e "${warning}To send an email alert, we need to have a Mail Transfer Agent (MTA) installed.">&2


# send email if free space is less than threshold and if smtp server is available
# if smtp server is not available, then echo message to stdout
checkfreespace () {
    FREESPACE=$(df -h / | grep -v Filesystem | awk '{print $4}')
    if [ $(echo $FREESPACE | cut -d'G' -f1) -lt $freespacethreshold ]; then
        echo "${error}Warning, free space is critically low!" >&2
        if nc -z smtp.gmail.com 587; then
            echo "Warning, free space is critically low!" | mail -s "Disk Space Alert" $alertaddress
        fi
    else 
        echo -e "${success}Free space is at $FREESPACE">&2
    fi
}


# Watch the free space on the root partition.
# If it falls below 1G, send an email to root.
while true; do
    checkfreespace
    sleep $sleepvalue
done
