if [ -f .env ]; then
  source .env
else
  echo "Error: .env file not found"
  exit 1
fi
# Authenticate and obtain an access token with application permissions
access_token=$(curl -X POST "https://login.microsoftonline.com/$tenant_id/oauth2/v2.0/token" -d "grant_type=client_credentials" -d "client_id=$client_id" -d "client_secret=$client_secret" -d "scope=https://graph.microsoft.com/.default" | jq -r .access_token)

echo $access_token
echo $user_id
# Define the desired presence status
presence_status='{
  "sessionId": "22553876-f5ab-4529-bffb-cfe50aa89f87",
  "availability": "Available",
  "activity": "Available",
  "expirationDuration": "PT1H"
}'

# Change the user's presence status
curl -X POST "https://graph.microsoft.com/v1.0/users/$user_id/presence/setPresence" -H "Authorization: Bearer $access_token" -H "Content-Type: application/json" -d "$presence_status"
