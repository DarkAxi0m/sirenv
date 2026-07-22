#!/bin/bash

set -e

if ! command -v fish &>/dev/null && ! dpkg-query -W -f='${Status}' fish 2>/dev/null | grep -q 'install ok installed'; then
    echo "Fish shell is not installed."
    exit 0
fi

current_shell="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$current_shell" == */fish ]]; then
    echo "Changing the login shell from Fish to Bash..."
    chsh -s /bin/bash "$USER"
fi

echo "Uninstalling Fish shell..."
sudo apt-get purge -y fish

fish_repo_list="/etc/apt/sources.list.d/shells:fish:release:3.list"
fish_repo_key="/etc/apt/trusted.gpg.d/shells_fish_release_3.gpg"

if [[ -e "$fish_repo_list" ]]; then
    sudo rm -- "$fish_repo_list"
fi

if [[ -e "$fish_repo_key" ]]; then
    sudo rm -- "$fish_repo_key"
fi

echo "Fish shell has been removed."
