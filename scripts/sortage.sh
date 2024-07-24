#!/bin/bash

figlet Sortage!

DOWNLOAD_DIR="$HOME/Downloads"
BASE_DIR="$DOWNLOAD_DIR/Sortage"


echo "Sorting files into: $BASE_DIR"


mkdir -p "${BASE_DIR}/videos"
mkdir -p "${BASE_DIR}/images"
mkdir -p "${BASE_DIR}/zips"
mkdir -p "${BASE_DIR}/pdfs"
mkdir -p "${BASE_DIR}/docs"
mkdir -p "${BASE_DIR}/dev"
mkdir -p "${BASE_DIR}/exeiso"

# Move video files
find "${DOWNLOAD_DIR}" -path "${BASE_DIR}" -prune -o -type f \( -iname "*.mp4" -o -iname "*.avi" -o -iname "*.webm" -o -iname "*.mov" -o -iname "*.mkv" \) -print -exec mv {} "${BASE_DIR}/videos/" \; 

# Move image files
find "${DOWNLOAD_DIR}" -path "${BASE_DIR}" -prune -o -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.xcf" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" \) -print -exec mv {} "${BASE_DIR}/images/" \;

# Move compressed files
find "${DOWNLOAD_DIR}" -path "${BASE_DIR}" -prune -o -type f \( -iname "*.zip" -o -iname "*.rar" -o -iname "*.7z" -o -iname "*.tar.gz" \) -print -exec mv {} "${BASE_DIR}/zips/" \; 

# Move PDF files
find "${DOWNLOAD_DIR}" -path "${BASE_DIR}" -prune -o -type f \( -iname "*.pdf" \) -print -exec mv {} "${BASE_DIR}/pdfs/" \; 

# Move document files
find "${DOWNLOAD_DIR}" -path "${BASE_DIR}" -prune -o -type f \( -iname "*.doc" -o -iname "*.docx" -o -iname "*.ics" -o -iname "*.eml" -o -iname "*.odt" -o -iname "*.dotx" -o -iname "*.ppt" -o -iname "*.pptx" -o -iname "*.xls" -o -iname "*.xlsm" -o -iname "*.xlsx" \) -print -exec mv {} "${BASE_DIR}/docs/" \; 

# Move development files (SQL, JSON, JavaScript, Text files)
find "${DOWNLOAD_DIR}" -path "${BASE_DIR}" -prune -o -type f \( -iname "*.sql" -o -iname "*.json" -o -iname "*.md" -o -iname "*.pem" -o -iname "*.bak" -o -iname "*.yml" -o -iname "*.csv" -o -iname "*.html" -o -iname "*.js" -o -iname "*.txt" \) -print -exec mv {} "${BASE_DIR}/dev/" \;


find "${DOWNLOAD_DIR}" -path "${BASE_DIR}" -prune -o -type f \( -iname "*.iso" -o -iname "*.exe" -o -iname "*.sh" -o -iname "*.msi" -o -iname "*.deb" -o -iname "*.rpm"  \) -print -exec mv {} "${BASE_DIR}/exeiso/" \; 


find "${DOWNLOAD_DIR}" -type f -iname "*.torrent" -exec rm {} +


echo "Sorting complete."

