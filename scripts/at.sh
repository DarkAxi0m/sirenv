#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  source .env
else
  echo "Error: .env file not found"
  exit 1
fi

##
##redirect_uri="http://localhost"
#scope="User.Read Presence.ReadWrite"

# Microsoft Graph API endpoint for obtaining an access token
#token_url="https://login.microsoftonline.com/common/oauth2/v2.0/token"

# Authenticate and obtain an access token interactively
#az login --allow-no-subscriptions
access_token=$(az account get-access-token --resource https://presence.teams.microsoft.com --query accessToken --output tsv)
api_url="https://presence.teams.microsoft.com/v1/me/forceavailability/"
presence_status='{"availability": "Available"}'
response=$(curl  --location --request PUT  "$api_url" --header "Authorization: Bearer $access_token" --header 'Content-Type: application/json' --data-raw '{"availability": "Busy"}')
if [ $? -eq 0 ]; then
  echo "Response:"
  echo "$response"
else
  echo "Error: Request failed"
fi
