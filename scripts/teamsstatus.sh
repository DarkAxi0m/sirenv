#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <status>"
    echo "Available statuses:"
    echo "  - Available"
    echo "  - Away"
    echo "  - BeRightBack"
    echo "  - Busy"
    echo "  - DoNotDisturb"
    echo "  - Offline"
    exit 1
fi

status=$1
access_token=$(az account get-access-token --resource https://presence.teams.microsoft.com --query accessToken --output tsv)
api_url="https://presence.teams.microsoft.com/v1/me/forceavailability/"
presence_status="{\"availability\": \"$status\"}"
curl  --location --request PUT  "$api_url" --header "Authorization: Bearer $access_token" --header 'Content-Type: application/json' --data-raw "$presence_status" &


