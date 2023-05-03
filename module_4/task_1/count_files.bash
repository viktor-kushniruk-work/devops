#!/usr/bin/env bash

# count the number of files that exist in given directory and its subdirectories.

# set up the colors to use for output
success='\033[0;32m'
nocolor='\033[0m'

# set the directory to search
if [ -d "$1" ]; then
    searchdir="$1"
elif [ -z "$1" ]; then
    searchdir="."
else
    echo "Error: $1 is not a directory">&2
    exit 1
fi

echo "⏳⏳⏳ Searching for files in $searchdir ⏳⏳⏳"

# count the number of files in the given directory and its subdirectories
find "$searchdir" -type f | wc -l | echo -e "${success}There are $(cat) files in $searchdir${nocolor}"
