#!/usr/bin/env bash
# Usage: ./clean.sh [--deep]
set -euo pipefail

SRC="${SRC_DIR:-$HOME/Downloads/dwhelper}"
HOST="${HOST_ADDR:-10.1.1.20}"
DEST_PATH="${DEST_PATH:-/mnt/Pool1/Recv/dwhelper}"
REMOTE_USER="${REMOTE_USER:-$USER}"
DEST="${REMOTE_USER}@${HOST}:${DEST_PATH}"

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
}

main "$@"
