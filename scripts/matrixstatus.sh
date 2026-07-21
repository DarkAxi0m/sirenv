#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <status> [status message]"
    echo "Available statuses:"
    echo "  - online"
    echo "  - unavailable"
    echo "  - offline"
    echo ""
    echo "  - Back"
    echo "  - Away"
    echo "  - Busy"
    echo "  - Coffee"
    exit 1
fi

status=$1
shift
status_msg="$*"

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
if [ -f "$script_dir/.env" ]; then
    source "$script_dir/.env"
fi

MATRIX_URL=${MATRIX_URL:-https://matrix.accede.au}
MATRIX_URL=${MATRIX_URL%/}
MATRIX_USER_ID=${MATRIX_USER_ID:-@chris:matrix.accede.au}
MATRIX_DISPLAY_NAME=${MATRIX_DISPLAY_NAME:-Chris}

if [ -z "$MATRIX_ACCESS_TOKEN" ]; then
    echo "MATRIX_ACCESS_TOKEN is not set in .env; starting Matrix SSO login."
    python3 "$script_dir/matrix-sso-token.py" --homeserver "$MATRIX_URL" --env-file "$script_dir/.env" || exit 1
    source "$script_dir/.env"
fi

if [ -z "$MATRIX_ACCESS_TOKEN" ]; then
    echo "MATRIX_ACCESS_TOKEN is still not set after Matrix SSO login."
    exit 1
fi

set_presence() {
    local presence=$1
    local message=$2
    local escaped_message
    local encoded_user_id
    local payload

    escaped_message=$(printf '%s' "$message" | sed 's/\\/\\\\/g; s/"/\\"/g')
    encoded_user_id=$(urlencode "$MATRIX_USER_ID")

    if [ -n "$message" ]; then
        payload="{\"presence\":\"$presence\",\"status_msg\":\"$escaped_message\"}"
    else
        payload="{\"presence\":\"$presence\",\"status_msg\":\"\"}"
    fi

    curl -i -X PUT \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $MATRIX_ACCESS_TOKEN" \
        -d "$payload" \
        "$MATRIX_URL/_matrix/client/v3/presence/$encoded_user_id/status"
}

json_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

urlencode() {
    python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$1"
}

set_display_name() {
    local display_name=$1
    local escaped_display_name
    local encoded_user_id

    escaped_display_name=$(json_escape "$display_name")
    encoded_user_id=$(urlencode "$MATRIX_USER_ID")

    curl -i -X PUT \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $MATRIX_ACCESS_TOKEN" \
        -d "{\"displayname\":\"$escaped_display_name\"}" \
        "$MATRIX_URL/_matrix/client/v3/profile/$encoded_user_id/displayname"
}

case $status in
  "Back")
    set_display_name "$MATRIX_DISPLAY_NAME"
    set_presence "online" "$status_msg"
    ;;
  "Away")
    if [ -z "$status_msg" ]; then
        status_msg="Away"
    fi
    set_display_name "$MATRIX_DISPLAY_NAME - 🟡 $status_msg"
    set_presence "unavailable" "$status_msg"
    ;;
  "Busy")
    if [ -z "$status_msg" ]; then
        status_msg="Busy"
    fi
    set_display_name "$MATRIX_DISPLAY_NAME - 🔴 $status_msg"
    set_presence "unavailable" "$status_msg"
    ;;
  "Coffee")
    if [ -z "$status_msg" ]; then
        status_msg="Coffee BRB"
    fi
    set_display_name "$MATRIX_DISPLAY_NAME - ☕ $status_msg"
    set_presence "unavailable" "$status_msg"
    ;;
  "online")
    set_display_name "$MATRIX_DISPLAY_NAME"
    set_presence "$status" "$status_msg"
    ;;
  "unavailable")
    if [ -n "$status_msg" ]; then
        set_display_name "$MATRIX_DISPLAY_NAME - 🟡 $status_msg"
    else
        set_display_name "$MATRIX_DISPLAY_NAME - 🟡 Away"
    fi
    set_presence "$status" "$status_msg"
    ;;
  "offline")
    if [ -n "$status_msg" ]; then
        set_display_name "$MATRIX_DISPLAY_NAME - ⚫ $status_msg"
    else
        set_display_name "$MATRIX_DISPLAY_NAME - ⚫ Offline"
    fi
    set_presence "$status" "$status_msg"
    ;;
  *)
    echo "Unknown Matrix presence: $status"
    echo "Use one of: online, unavailable, offline, Back, Away, Busy, Coffee"
    exit 1
    ;;
esac
