#!/bin/bash

set -e

SHARE_NAME="${1:-$(basename "$PWD")}"
SHARE_PATH="$PWD"

sudo mkdir -p /etc/samba

if ! command -v smbd >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y samba
fi

sudo tee -a /etc/samba/smb.conf >/dev/null <<EOF

[$SHARE_NAME]
    path = $SHARE_PATH
    browseable = yes
    read only = no
    guest ok = yes
    force user = $USER
EOF

sudo systemctl restart smbd

echo "Shared: $SHARE_PATH"
echo "Share:  //$HOSTNAME/$SHARE_NAME"
