#!/bin/bash

vimrc_file="$HOME/.vimrc"
nvim_path="$HOME/.config/nvim"
sir_nvim_path="$(pwd)/nvim"
PACKER_PATH="~/.local/share/nvim/site/pack/packer/start/packer.nvim"


check_color_support() {
    if [[ -t 1 ]]; then
        if tput setaf 1 &>/dev/null; then
            return 0
        else
            return 1
        fi
    else
        echo "Not running in a terminal?"
	exit 1
    fi
}

if check_color_support; then
 RED=$(tput setaf 1)
 GREEN=$(tput setaf 2)
 YELLOW=$(tput setaf 3)
 NC=$(tput sgr0)
else
 RED='['
 GREEN='['
 YELLOW='['
 NC=']'  
fi


echo "${RED}Lets get this going...${NC}"

if [ -f /etc/os-release ]; then
   . /etc/os-release
   if [[ "$ID" != "debian" && "$ID" != "ubuntu" && "$ID" != "pop" ]]; then
      echo "This script is meant to be run on Debian, Ubuntu or POPOS systems only. Not tested, because i don't needed it"
      echo "found: $ID"
      exit 1
   fi
else 
   echo "This script requires /etc/os-release to determine the distribution."
   exit 1
fi

if command -v sudo &>/dev/null; then
	   echo "# ${GREEN}sudo is installed.${NC}"
    else
	   
	     echo "sudo not isntalled, Please su -, and get that going first"
              exit 1
        fi	      
	    

echo "# ${GREEN}installing somethings i use often etc....${NC}"
sudo apt-get update
sudo apt-get install -y git curl btop neovim tmux jq figlet
echo ${GREEN}
figlet "Lets Go!"
touch "$vimrc_file"
echo ${NC}
echo "# ${GREEN} NeoVim Packer Time... ${NC}"

if [ -d "$PACKER_PATH" ]; then
       echo "Assuming it's installed"
    else
      git clone --depth 1 https://github.com/wbthomason/packer.nvim "$PACKER_PATH"
fi

cd "$PACKER_PATH" && git pull

echo "# ${GREEN} NeoVim Config... ${NC}"
if [ -d "$nvim_path" ]; then
    echo "Found folder, checking type ($nvim_path)"

    if [ -L "$nvim_path" ]; then
        echo "$nvim_path is a symbolic link"
    elif [ -d "$nvim_path" ]; then
        echo "$nvim_path is a directory, renaming it to .old"
        mv "$nvim_path" "$nvim_path.old"
        ln -s "$sir_nvim_path" "$nvim_path"
        echo "Created symbolic link"
    else
        echo "i don't know what the path is?"
    fi
else
    ln -s "$sir_nvim_path" "$nvim_path"
    echo "Created symbolic link"
fi

echo "${YELLOW} Done for now... ${NC}"
