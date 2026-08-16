#!/usr/bin/env bash
# Usage: ./clean.sh [--deep]
set -euo pipefail

CONFIG_FILE="${SIRENV_ENV_FILE:-$HOME/.config/sirenv.env}"
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
fi

SRC="${SRC_DIR:-$HOME/Downloads/dwhelper}"
HOST="${HOST_ADDR:-}"
DEST_PATH="${DEST_PATH:-}"
REMOTE_USER="${REMOTE_USER:-$USER}"
DEST="${REMOTE_USER}@${HOST}:${DEST_PATH}"
STASH_URL="${STASH_URL:-}"
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
  find "$SRC" -mindepth 1 -depth -type d -empty -delete
}

build_stash_scan_input() {
  jq -cn \
    --arg mode "$STASH_SCAN_MODE" \
    --arg path "$STASH_SCAN_PATH" \
    --arg rescan "${STASH_SCAN_RESCAN:-}" \
    --arg covers "${STASH_SCAN_GENERATE_COVERS:-}" \
    --arg previews "${STASH_SCAN_GENERATE_PREVIEWS:-}" \
    --arg image_previews "${STASH_SCAN_GENERATE_IMAGE_PREVIEWS:-}" \
    --arg sprites "${STASH_SCAN_GENERATE_SPRITES:-}" \
    --arg phashes "${STASH_SCAN_GENERATE_PHASHES:-}" \
    --arg image_phashes "${STASH_SCAN_GENERATE_IMAGE_PHASHES:-}" \
    --arg thumbnails "${STASH_SCAN_GENERATE_THUMBNAILS:-}" \
    --arg clip_previews "${STASH_SCAN_GENERATE_CLIP_PREVIEWS:-}" \
    '
      def optbool($value):
        if $value == "" then
          null
        elif ($value | ascii_downcase) == "true" then
          true
        elif ($value | ascii_downcase) == "false" then
          false
        else
          error("Expected boolean true/false, got: \($value)")
        end;

      {
        paths: (if $mode == "selective" then [$path] else null end),
        rescan: optbool($rescan),
        scanGenerateCovers: optbool($covers),
        scanGeneratePreviews: optbool($previews),
        scanGenerateImagePreviews: optbool($image_previews),
        scanGenerateSprites: optbool($sprites),
        scanGeneratePhashes: optbool($phashes),
        scanGenerateImagePhashes: optbool($image_phashes),
        scanGenerateThumbnails: optbool($thumbnails),
        scanGenerateClipPreviews: optbool($clip_previews)
      }
      | with_entries(select(.value != null))
    '
}

trigger_stash_scan() {
  local query payload input_json

  if [[ -z "$STASH_API_KEY" ]]; then
    echo "Skipping Stash scan trigger: STASH_API_KEY is not set."
    return 0
  fi

  case "$STASH_SCAN_MODE" in
    full|selective)
      ;;
    *)
      echo "Skipping Stash scan trigger: unsupported STASH_SCAN_MODE '$STASH_SCAN_MODE'."
      return 0
      ;;
  esac

  query='mutation MetadataScan($input: ScanMetadataInput!) { metadataScan(input: $input) }'
  if ! input_json="$(build_stash_scan_input)"; then
    echo "Skipping Stash scan trigger: invalid scan option value."
    return 0
  fi

  payload=$(jq -cn \
    --arg query "$query" \
    --argjson input "$input_json" \
    '{query: $query, variables: {input: $input}}')

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
  [[ -n "$HOST" ]] || { echo "Missing HOST_ADDR in sirlan config." >&2; exit 1; }
  [[ -n "$DEST_PATH" ]] || { echo "Missing DEST_PATH in sirlan config." >&2; exit 1; }

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
