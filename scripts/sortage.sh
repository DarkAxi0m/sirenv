#!/usr/bin/env bash
set -euo pipefail

DOWNLOAD_DIR="$HOME/Downloads"
BASE_DIR="$DOWNLOAD_DIR/Sortage"
IGNORE_DIR="$DOWNLOAD_DIR/dwhelper"

if command -v figlet >/dev/null 2>&1; then
    figlet Sortage!
else
    echo "Sortage!"
fi

echo "Sorting files into: $BASE_DIR"
echo "Ignoring: $IGNORE_DIR"

mkdir -p "$BASE_DIR"/{videos,images,zips,pdfs,docs,dev,exeiso,3d}

find_downloads() {
    find "$DOWNLOAD_DIR" \
        \( -path "$BASE_DIR" -o -path "$IGNORE_DIR" \) -prune -o \
        "$@"
}

move_matches() {
    local target_dir=$1
    shift

    find_downloads -type f \( "$@" \) -print -exec mv -t "$target_dir" {} +
}

delete_matches() {
    find_downloads -type f \( "$@" \) -print -exec rm -f -- {} +
}

move_matches "$BASE_DIR/videos" \
    -iname "*.mp4" -o -iname "*.avi" -o -iname "*.webm" -o -iname "*.mov" -o -iname "*.mkv"

move_matches "$BASE_DIR/images" \
    -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.xcf" -o -iname "*.png" -o \
    -iname "*.svg" -o -iname "*.gif" -o -iname "*.bmp"

move_matches "$BASE_DIR/zips" \
    -iname "*.zip" -o -iname "*.rar" -o -iname "*.7z" -o -iname "*.tar.gz"

move_matches "$BASE_DIR/pdfs" \
    -iname "*.pdf"

move_matches "$BASE_DIR/docs" \
    -iname "*.doc" -o -iname "*.docx" -o -iname "*.ics" -o -iname "*.eml" -o -iname "*.odt" -o \
    -iname "*.dotx" -o -iname "*.ppt" -o -iname "*.pptx" -o -iname "*.xls" -o -iname "*.xlsm" -o \
    -iname "*.xlsx"

move_matches "$BASE_DIR/dev" \
    -iname "*.sql" -o -iname "*.json" -o -iname "*.md" -o -iname "*.pem" -o -iname "*.bak" -o \
    -iname "*.yml" -o -iname "*.csv" -o -iname "*.html" -o -iname "*.js" -o -iname "*.txt"

move_matches "$BASE_DIR/exeiso" \
    -iname "*.iso" -o -iname "*.exe" -o -iname "*.sh" -o -iname "*.msi" -o -iname "*.deb" -o \
    -iname "*.rpm"

delete_matches -iname "*.torrent"

move_matches "$BASE_DIR/3d" \
    -iname "*.stl" -o -iname "*.3mf" -o -iname "*.step"

echo "Sorting complete."

total_space_used=$(du -sh "$DOWNLOAD_DIR" | cut -f1)
echo "Total space used by $DOWNLOAD_DIR: $total_space_used"
