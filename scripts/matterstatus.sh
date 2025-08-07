#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <status>"
    echo "Available statuses:"
    echo "  - online"
    echo "  - away"
    echo "  - offline"
    echo ""
    echo "  - Busy"
    echo "  - Coffee"
    exit 1
fi

status=$1

source .env


case $status in
  "Back")
  
  curl -i -X DELETE -H "Authorization: Bearer $MM_ACCESS_TOKEN" "$MM_URL/api/v4/users/me/status/custom"
  curl -i -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer $MM_ACCESS_TOKEN" -d "{\"user_id\":\"$MM_USER_ID\",\"status\":\"online\"}" "$MM_URL/api/v4/users/me/status"


  
  ;;
  "Busy")
echo -n "Enter duration for DND mode in minutes (e.g., 30): "
read duration_minutes
current_time=$(date +%s)
dnd_end_time=$((current_time + duration_minutes * 60))
curl -i -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer $MM_ACCESS_TOKEN" -d "{\"user_id\":\"$MM_USER_ID\",\"status\":\"dnd\",\"dnd_end_time\":$dnd_end_time}" "$MM_URL/api/v4/users/me/status"
    ;;
  "Busy")
  
curl -i -X PUT -H 'Content-Type: application/json' -H "Authorization: Bearer $MM_ACCESS_TOKEN" -d "{\"emoji\":\"coffee\",\"text\":\"Coffee BRB\"}" "$MM_URL/api/v4/users/me/status/custom"
  
  
  ;;
  *)
curl -i -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer $MM_ACCESS_TOKEN" -d "{\"user_id\":\"$MM_USER_ID\",\"status\":\"$status\"}" "$MM_URL/api/v4/users/me/status"
    ;;
esac


