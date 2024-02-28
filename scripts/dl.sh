#!/bin/bash

# File to store domain, download type, and default path mappings
mapping_file=".download_mappings.txt"

# Function to extract domain from URL
extract_domain() {
    local url="$1"
    local domain
    # Remove protocol
    domain="${url#*://}"
    # Remove path
    domain="${domain%%/*}"
    echo "$domain"
}

# Function to prompt user for download type
prompt_download_type() {
    local domain="$1"
    local download_type
    read -p "Enter download type for domain '$domain' (curl, wget, youtube-dl): " download_type
    echo "$download_type"
}

# Function to prompt user for default download path
prompt_download_path() {
    local domain="$1"
    local download_path
    read -p "Enter default download path for domain '$domain' (default: ~/Downloads): " download_path
    # Use default path if user input is empty
    download_path="${download_path:-$HOME/Downloads}"
    echo "$download_path"
}

# Check if number of arguments is less than 1
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [command] <url>"
    exit 1
fi

# Default command to "download" if not provided
if [ "$#" -eq 1 ]; then
    command=""
    url="$1"
else
    command="$1"
    url="$2"
fi

# Set default download directory to user's Downloads directory
download_path="$HOME/Downloads"

# Extract domain from URL
domain=$(extract_domain "$url")

# Check if domain exists in the mapping file
if [ -f "$mapping_file" ] && grep -q "^$domain " "$mapping_file"; then
    # Get download type and default path from mapping file
    download_type=$(grep "^$domain " "$mapping_file" | awk '{print $2}')
    download_path=$(grep "^$domain " "$mapping_file" | awk '{print $3}')
    echo "Using stored download type '$download_type' and default path '$download_path' for domain: $domain"
else
    # Prompt user for download type and default path if domain not found in mapping file
    download_type=$(prompt_download_type "$domain")
    download_path=$(prompt_download_path "$domain")
    # Update mapping file with the new domain, download type, and default path
    echo "$domain $download_type $download_path" >> "$mapping_file"
    echo "Added domain '$domain' with download type '$download_type' and default path '$download_path' to $mapping_file"
fi

echo "-------------------------------"

case "$command" in
    download | d)
        download_path="$HOME/Downloads"
        ;;
    current | c)
        download_path="$(pwd)"
        ;;
    music | m)
        download_path="/s/Music"
        ;;
esac

echo "Downloading to $download_path"

# Perform action based on the download type
case "$download_type" in
    curl)
        echo "Using curl to download $url"
        ;;
    wget)
        echo "Using wget to download $url"
        ;;
    youtube-dl)
        echo "Using youtube-dl to download $url"
        
        cd $download_path
        python3 "$HOME/sirenv/bin/youtube-dl" "$url"

        ;;
    *)
        echo "Invalid download type: $download_type"
        exit 1
        ;;
esac


