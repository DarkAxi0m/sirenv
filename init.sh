#!/bin/bash

vimrc_file="$HOME/.vimrc"
source_line="source $(pwd)/Vundle.vim"
VUNDLE_PATH=~/.vim/bundle/Vundle.vim

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
   if [[ "$ID" != "debian" && "$ID" != "ubuntu" ]]; then
      echo "This script is meant to be run on Debian or Ubuntu systems only. Not tested, because i don't needed it"
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
echo ${NC}
echo "# ${GREEN}Vundle Time... ${NC}"


if [ -d "$VUNDLE_PATH" ]; then
	  echo "Assuming it's installed"
    else
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

touch "$vimrc_file"

if grep -Fxq "$source_line" "$vimrc_file"; then
    echo "Vundle already present in .vimrc"
else
    echo "$source_line" >> "$vimrc_file"
    echo "Vundle added to .vimrc"
fi


fi
echo "installing plugins...."
vim +PluginInstall +qall



echo "${YELLOW} Done for now... ${NC}"
