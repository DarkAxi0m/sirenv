#!/bin/bash

# Function to ask for confirmation
confirm_action() {
    read -p "Are you sure you want to proceed? (y/n) " -n 1 -r
    echo    # Move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        echo "Operation cancelled."
        exit 1
    fi
}

# Check if the argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file/folder>"
    exit 1
fi

# Convert the target to an absolute path (handles both relative and absolute paths)
TARGET=$(realpath "$1")
HOME_DIR=$(eval echo ~$USER)

# Check if the file/folder is in the home directory
if [[ $TARGET != $HOME_DIR* ]]; then
    echo "Error: The file or folder is not in the home directory."
    exit 1
fi

# Find the 'archive' directory
DIR_TO_SEARCH=$(dirname "$TARGET")
ARCHIVE_DIR=""

while [[ "$DIR_TO_SEARCH" != "/" ]]; do
    if [ -d "$DIR_TO_SEARCH/archive" ]; then
        ARCHIVE_DIR="$DIR_TO_SEARCH/archive"
        break
    fi
    # Break the loop if we have moved beyond the home directory
    if [[ "$DIR_TO_SEARCH" == "$HOME_DIR" || "$DIR_TO_SEARCH" == "/" ]]; then
        break
    fi
    DIR_TO_SEARCH=$(dirname "$DIR_TO_SEARCH")
done

if [ -z "$ARCHIVE_DIR" ]; then
    echo "Error: 'archive' directory not found in the path or any of its parent directories."
    exit 1
fi

# List of file extensions to be moved without creating a tar.gz archive
EXTENSIONS_TO_MOVE=("iso" "mp4", "pdf", 'zip','gz')  # Add more extensions as needed

# Extract the file extension of the target
file_extension="${TARGET##*.}"

# Check if the file extension is in the list of extensions to be moved directly
if [[ " ${EXTENSIONS_TO_MOVE[@]} " =~ " $file_extension " ]]; then
    echo "Moving $TARGET to $ARCHIVE_DIR."
    confirm_action
    mv "$TARGET" "$ARCHIVE_DIR"
    echo "File moved successfully to $ARCHIVE_DIR."
else
    # Create a tar.gz archive of the file/folder
    ARCHIVE_NAME=$(basename "$TARGET")
    tar -czf "$ARCHIVE_NAME.tar.gz" -C "$(dirname "$TARGET")" "$(basename "$TARGET")"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create archive."
        exit 1
    fi

    # Ask for confirmation before moving the archive
    echo "About to move $ARCHIVE_NAME.tar.gz to $ARCHIVE_DIR."
    confirm_action

    # Move the archive to the 'archive' directory
    mv "$ARCHIVE_NAME.tar.gz" "$ARCHIVE_DIR"

    # Ask for confirmation before removing the original file/folder
    echo "About to remove the original file/folder: $TARGET."
    confirm_action

    # Remove the original file/folder
    rm -rf "$TARGET"

    echo "File/Folder archived and moved successfully to $ARCHIVE_DIR."
fi

