#!/bin/bash

vimrc_file="$HOME/.vimrc"
nvim_path="$HOME/.config/nvim"
bashrc_path="$HOME/.bashrc"
fishconfig_path="$HOME/.config/fish/config.fish"
config_path="$HOME/.config"
wezterm_path="$HOME/.wezterm.lua"


PACKER_PATH="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"

sir_nvim_path="$(pwd)/nvim"
sir_bashrc_path="$(pwd)/bashrc"
sir_fishconfig_path="$(pwd)/config.fish"
sir_tmux_path="$(pwd)/tmux"
sir_ill_path="$(pwd)/illdo/ill.sh"
sir_yazi_path="$(pwd)/bin/yazi/yazi"
sir_archive="$(pwd)/scripts/archive.sh"
sir_wezterm="$(pwd)/wezterm.lua"

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
sudo apt-get install -y git curl btop tmux jq figlet fzf wget screen zoxide bat

mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat


echo ${GREEN}
figlet "Lets Go!"
echo "----------------"
install/fish.sh
install/neovim.sh
install/lazygit.sh
install/fzf.sh
echo "----------------"
touch "$vimrc_file"
echo ${NC}
echo "# ${GREEN} NeoVim Packer Time... ${NC}"

echo "$PACKER_PATH"
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
echo "# ${GREEN} Checking bashrc... ${NC}"
source_line="source $sir_bashrc_path"

if grep -Fxq "$source_line" "$bashrc_path"; then
    echo "Line already present in .bashrc"
else
    echo "$source_line" >> "$bashrc_path"
    echo "Line added to .bashrc"
    source $bashrc_path
fi

if [ -d "$fishconfig_path" ]; then
   echo "No fish..."
else
 echo "# ${GREEN} Checking fish... ${NC}"
	source_line="source $sir_fishconfig_path"

	if grep -Fxq "$source_line" "$fishconfig_path"; then
	    echo "Line already present in fish config"
	else
	    echo "$source_line" >> "$fishconfig_path"
	    echo "Line added to  fish config"
	    source $fishconfig_path
	fi

fi

echo "# ${GREEN} tmux... ${NC}"
ln -s "$sir_tmux_path" "$config_path"
echo "Created symbolic link"


echo "# ${GREEN} Misc Dirs... ${NC}"
mkdir "$HOME/workbox"
mkdir "$HOME/sandbox"
echo "done"

ln -s "~/bin/ill" "$sir_ill_path"  
ln -s "~/bin/yazi" "$sir_yazi_path"  
ln -s "$sir_archive" "~/.local/bin/archive"
ln -s "$sir_wezterm" "$wezterm_path"

echo "${YELLOW} Done for now... ${NC}"
