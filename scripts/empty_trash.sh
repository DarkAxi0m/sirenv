#!/bin/bash

figlet Empty Trash...

TRASH_DIR="$HOME/.local/share/Trash"


# Ensure the trash directory exists
if [ -d "$TRASH_DIR" ]; then
    # Empty the trash files
    rm -rf "${TRASH_DIR}/files/"*
    echo "Emptied trash files."

    # Empty the trash info
    rm -rf "${TRASH_DIR}/info/"*
    echo "Emptied trash info."

    # Empty the trash metadata
    rm -rf "${TRASH_DIR}/metadata/"*
    echo "Emptied trash metadata."

    echo "Trash has been emptied."
else
    echo "Trash directory does not exist."
fi

