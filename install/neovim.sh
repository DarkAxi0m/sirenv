#!/bin/bash

if ! command -v nvim &> /dev/null; then
    echo "Neovim is not installed."
    nvim_version="0.01"
else
    nvim_version=$(nvim --version | head -n 1 | awk '{print $2}')
fi

# Define the minimum version
minimum_version="0.10"

# Compare the versions
if [[ "$(echo "$nvim_version < $minimum_version" | bc -l)" -eq 1 ]]; then
    echo "Neovim version is less than $minimum_version"
    sudo apt-get remove neovim
#    i don't like this locatioN

    if [ -d "/usr/local/neovim" ]; then
	echo "NeoVim Git Found"
    else
	sudo mkdir -p /usr/local/neovim
        sudo chown -R $(whoami):$(whoami) /usr/local/neovim
        git clone https://github.com/neovim/neovim /usr/local/neovim	
    fi
    
    cd /usr/local/neovim
    git checkout master
    git pull 

    sudo apt-get install ninja-build gettext cmake unzip curl

    make CMAKE_BUILD_TYPE=RelWithDebInfo
   
    sudo make install

else
    echo "Neovim version is $nvim_version, which is greater than or equal to $minimum_version"
fi

