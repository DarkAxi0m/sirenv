#!/usr/bin/env bash
# Usage: ./clean.sh [--deep]
set -euo pipefail

CONFIG_FILE="${SIRENV_ENV_FILE:-$HOME/.config/sirenv.env}"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
fi

SRC="${SRC_DIR:-$HOME/Downloads/dwhelper}"
HOST="${HOST_ADDR:-10.1.1.20}"
DEST_PATH="${DEST_PATH:-/mnt/Pool1/Recv/dwhelper}"
REMOTE_USER="${REMOTE_USER:-$USER}"
DEST="${REMOTE_USER}@${HOST}:${DEST_PATH}"
STASH_URL="${STASH_URL:-http://10.1.1.31:9999}"
STASH_API_KEY="${STASH_API_KEY:-}"
STASH_SCAN_PATH="${STASH_SCAN_PATH:-$DEST_PATH}"
STASH_SCAN_MODE="${STASH_SCAN_MODE:-selective}"

DEEP=0
[[ "${1-}" == "--deep" ]] && DEEP=1

check_host() {
  timeout 3 bash -c ">/dev/tcp/${HOST}/22" 2>/dev/null
}

ensure_remote_dir() {
  ssh -o BatchMode=yes -o ConnectTimeout=5 "${REMOTE_USER}@${HOST}" "mkdir -p '${DEST_PATH}'"
}

move_all() {
  rsync -a --remove-source-files --info=stats1,progress2 --human-readable \
    -e ssh "${SRC}/" "${DEST}/"
}

move_old() {
  ( cd "$SRC"
    find . -type f -mtime +7 -print0 \
    | rsync -a --remove-source-files --from0 --files-from=- \
        --info=stats1,progress2 --human-readable \
        -e ssh "${SRC}/" "${DEST}/"
  )
}

cleanup_empty_dirs() {
  find "$SRC" -depth -type d -empty -delete
}

trigger_stash_scan() {
  local query payload

  if [[ -z "$STASH_API_KEY" ]]; then
    echo "Skipping Stash scan trigger: STASH_API_KEY is not set."
    return 0
  fi

  case "$STASH_SCAN_MODE" in
    full)
      query='mutation { metadataScan(input: {}) }'
      ;;
    selective)
      query='mutation MetadataScan($input: ScanMetadataInput!) { metadataScan(input: $input) }'
      payload=$(jq -cn \
        --arg query "$query" \
        --arg path "$STASH_SCAN_PATH" \
        '{query: $query, variables: {input: {paths: [$path]}}}')
      ;;
    *)
      echo "Skipping Stash scan trigger: unsupported STASH_SCAN_MODE '$STASH_SCAN_MODE'."
      return 0
      ;;
  esac

  if [[ "$STASH_SCAN_MODE" == "full" ]]; then
    payload=$(jq -cn --arg query "$query" '{query: $query}')
  fi

  echo "Triggering Stash scan via ${STASH_URL}..."
  if ! curl -fsS \
    -H "ApiKey: ${STASH_API_KEY}" \
    -H "Content-Type: application/json" \
    --data "$payload" \
    "${STASH_URL%/}/graphql" >/dev/null; then
    echo "Stash scan trigger failed."
  fi
}

main() {
  [[ -d "$SRC" ]] || { echo "Missing source: $SRC" >&2; exit 1; }

  if ! check_host; then
    echo "Host ${HOST} not reachable; exiting."
    exit 0
  fi

  ensure_remote_dir

  if [[ "$DEEP" -eq 1 ]]; then
    move_all
  else
    move_old
  fi

  cleanup_empty_dirs
  trigger_stash_scan
}

main "$@"
