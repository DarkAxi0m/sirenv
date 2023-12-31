#!/bin/bash

access_token=$(az account get-access-token --resource https://presence.teams.microsoft.com --query accessToken --output tsv)
api_url="https://presence.teams.microsoft.com/v1/me/forceavailability/"
presence_status='{"availability": "BeRightBack"}'
curl  --location --request PUT  "$api_url" --header "Authorization: Bearer $access_token" --header 'Content-Type: application/json' --data-raw "$presence_status" &

xdotool key XF86AudioPlay &

amixer set Master mute &

wait


# Check if the gnome-screensaver-command or xdg-screensaver command is available
if command -v gnome-screensaver-command &> /dev/null; then
    gnome-screensaver-command -l
elif command -v xdg-screensaver &> /dev/null; then
    xdg-screensaver lock
else
    echo "Screen locking command not found. Please install gnome-screensaver or xdg-utils."
    exit 1
fi
