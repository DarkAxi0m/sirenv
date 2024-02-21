#!/bin/bash
#
echo -n "Are you sure you want to continue? (y/n): "
read -n 1 response

echo "--"


if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Exiting the script. Nothing has been executed."
    exit 1
fi

lock &
mydev stop &
teamsstatus.sh offline &
echo "Todo: Sortout backups" &



wait

figlet "Good bye"

sudo shutdown now
