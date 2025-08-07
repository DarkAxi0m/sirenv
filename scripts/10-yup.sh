#!/bin/sh
#
echo ""
docker ps --format '{{.Names}}|{{.Image}}|{{.Status}}' | while IFS="|" read -r name image status; do
    printf "📌 %-30s %-40s %-20s\n" "$name" "$image" "$status"
done

