#!/bin/bash
#



TARGET="/etc/update-motd.d/10-yup"
SOURCE="/home/chris/sirenv/scripts/10-yup.sh"

if [ ! -e "$TARGET" ]; then
    sudo ln -s "$SOURCE" "$TARGET"
fi
