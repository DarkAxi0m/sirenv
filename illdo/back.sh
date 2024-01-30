#!/bin/bash
gsettings set org.gnome.desktop.background picture-uri-dark file:///home/chris/Pictures/Wallpapers/52303684090_157b08692a_o.png

access_token=$(az account get-access-token --resource https://presence.teams.microsoft.com --query accessToken --output tsv)
api_url="https://presence.teams.microsoft.com/v1/me/forceavailability/"
presence_status='{"availability": "Available"}'
curl  --location --request PUT  "$api_url" --header "Authorization: Bearer $access_token" --header 'Content-Type: application/json' --data-raw "$presence_status"





