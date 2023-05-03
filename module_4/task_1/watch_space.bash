#!/usr/bin/env bash

# Set up the email address to send alerts to.
# takes an option for free space threshold
# takes an option for time to sleep between checks
alertaddress="vkushniruk1@gmail.com"

# get the options sleepvalue & freespacethreshold
# if no options are given, use the defaults
while getopts "s:f:" opt; do
  case $opt in
    s)
      sleepvalue=$OPTARG
      ;;
    f)
      freespacethreshold=$OPTARG
      ;;
    *)
      echo "Usage: $0 [-s sleepvalue] [-f freespacethreshold]" >&2
      exit 1
      ;;
  esac
done

if [[ -z $sleepvalue ]]; then
  sleepvalue=60
fi

if [[ -z $freespacethreshold ]]; then
  freespacethreshold=1
fi

if [[ ! $sleepvalue =~ ^[0-9]+$ ]]; then
  echo "Error: sleepvalue must be a positive integer" >&2
  exit 1
fi

if [[ ! $freespacethreshold =~ ^[0-9]+$ ]]; then
  echo "Error: freespacethreshold must be a positive integer" >&2
  exit 1
fi


warning='\033[1;33m'
success='\033[0;32m'
error='\033[1;31m'
nocolor='\033[0m' # No Color


read -p "Enter the email address to send alerts to: [$alertaddress]"
read -p "Enter the free space threshold in GB: [$freespacethreshold]"

echo -e "${warning}To send an email alert, we need to have a Mail Transfer Agent (MTA) installed.${nocolor}"

# send email if free space is less than threshold and if smtp server is available and echo message to stdout
checkfreespace () {
    FREESPACE=$(df -h / | grep -v Filesystem | awk '{print $4}')
    if [ $(echo $FREESPACE | cut -d'G' -f1) -lt $freespacethreshold ]; then
        echo -e "🚨🚨🚨 ${error}Warning, free space is critically low!${nocolor}" >&2
        if nc -z smtp.gmail.com 587; then
            echo sending email to $alertaddress
            echo "Warning, free space is critically low!" | mail -s "Disk Space Alert" $alertaddress
        fi
    else 
        echo -e "${success}Free space is at $FREESPACE${nocolor}"
    fi
}

while true; do
    checkfreespace
    sleep $sleepvalue
done
