#!/bin/bash
#

MOTD_DIR="/etc/update-motd.d"
CUSTOM_SCRIPT="$MOTD_DIR/10-yup"
SOURCE="/home/chris/sirenv/scripts/10-yup.sh"

# Remove unwanted MOTD components
sudo rm -f "$MOTD_DIR/50-motd-news" "$MOTD_DIR/10-help-text"

# Create symlink if missing
if [ ! -e "$CUSTOM_SCRIPT" ]; then
    sudo ln -s "$SOURCE" "$CUSTOM_SCRIPT"
fi
