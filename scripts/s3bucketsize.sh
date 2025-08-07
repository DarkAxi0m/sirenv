#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <bucket-name>"
  exit 1
fi

BUCKET_NAME="$1"

# Get sizes from object versions
OUTPUT=$(aws s3api list-object-versions --bucket "$BUCKET_NAME" --output json --query "[sum(Versions[].Size), length(Versions[])]" 2>/dev/null)

if [ $? -ne 0 ]; then
  echo "Error: Failed to access bucket '$BUCKET_NAME'. Check permissions or bucket name."
  exit 2
fi

TOTAL_SIZE=$(echo "$OUTPUT" | jq '.[0]')
TOTAL_OBJECTS=$(echo "$OUTPUT" | jq '.[1]')

if [ "$TOTAL_SIZE" == "null" ] || [ "$TOTAL_OBJECTS" == "null" ]; then
  TOTAL_SIZE=0
  TOTAL_OBJECTS=0
fi

echo "Bucket Name: $BUCKET_NAME"
echo "Total Objects (with versions): $TOTAL_OBJECTS"
echo "Total Size (bytes): $TOTAL_SIZE"
echo "Total Size (MB): $(echo "$TOTAL_SIZE / 1024 / 1024" | bc -l)"
echo "Total Size (TB): $(echo "$TOTAL_SIZE / 1024 / 1024 / 1024 / 1024" | bc -l)"

