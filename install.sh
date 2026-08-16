#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

vimrc_file="$HOME/.vimrc"
nvim_path="$HOME/.config/nvim"
bashrc_path="$HOME/.bashrc"
config_path="$HOME/.config"
wezterm_path="$HOME/.wezterm.lua"
sirenv_env_path="$HOME/.config/sirenv.env"
sirenv_env_template="$SCRIPT_DIR/config/sirenv.env.example"


PACKER_PATH="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"

sir_nvim_path="$SCRIPT_DIR/nvim"
sir_bashrc_path="$SCRIPT_DIR/bashrc"
sir_tmux_path="$SCRIPT_DIR/tmux"
sir_ill_path="$SCRIPT_DIR/illdo/ill.sh"
sir_yazi_path="$SCRIPT_DIR/bin/yazi"
sir_archive="$SCRIPT_DIR/scripts/archive"
sir_wezterm="$SCRIPT_DIR/wezterm.lua"

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

ensure_symlink() {
    local source_path="$1"
    local target_path="$2"

    if [ -L "$target_path" ]; then
        if [ "$(readlink "$target_path")" = "$source_path" ]; then
            echo "$target_path already points to $source_path"
            return 0
        fi
        rm -f "$target_path"
    elif [ -e "$target_path" ]; then
        echo "$target_path exists and is not a symlink, skipping."
        return 0
    fi

    ln -s "$source_path" "$target_path"
    echo "Created symbolic link: $target_path -> $source_path"
}

backup_dir_once() {
    local source_dir="$1"
    local backup_dir="${source_dir}.old"

    if [ ! -d "$source_dir" ] || [ -L "$source_dir" ]; then
        return 0
    fi

    if [ -e "$backup_dir" ]; then
        backup_dir="${source_dir}.old.$(date +%Y%m%d%H%M%S)"
    fi

    mv "$source_dir" "$backup_dir"
    echo "Moved $source_dir to $backup_dir"
}

ensure_sirenv_env() {
    local target="$sirenv_env_path"
    local template="$sirenv_env_template"
    local pending_block=""
    local appended=0
    local line
    local var_name

    mkdir -p "$(dirname "$target")"

    if [ ! -f "$template" ]; then
        echo "# ${YELLOW}sirenv env template not found at $template, skipping.${NC}"
        return 0
    fi

    if [ ! -f "$target" ]; then
        cp "$template" "$target"
        echo "# ${GREEN}Created $target from template.${NC}"
        return 0
    fi

    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ ^[[:space:]]*$ || "$line" =~ ^[[:space:]]*# ]]; then
            pending_block+="$line"$'\n'

            if [[ "$line" =~ ^[[:space:]]*#?[[:space:]]*export[[:space:]]+([A-Za-z_][A-Za-z0-9_]*)= ]]; then
                var_name="${BASH_REMATCH[1]}"
                if ! grep -Eq "^[[:space:]]*#?[[:space:]]*export[[:space:]]+${var_name}=" "$target"; then
                    if [ "$appended" -eq 0 ]; then
                        printf '\n# Added by sirenv installer from template.\n' >> "$target"
                        appended=1
                    fi
                    printf '%s' "$pending_block" >> "$target"
                fi
                pending_block=""
            fi

            continue
        fi

        if [[ "$line" =~ ^[[:space:]]*export[[:space:]]+([A-Za-z_][A-Za-z0-9_]*)= ]]; then
            var_name="${BASH_REMATCH[1]}"
            if ! grep -Eq "^[[:space:]]*#?[[:space:]]*export[[:space:]]+${var_name}=" "$target"; then
                if [ "$appended" -eq 0 ]; then
                    printf '\n# Added by sirenv installer from template.\n' >> "$target"
                    appended=1
                fi
                printf '%s%s\n' "$pending_block" "$line" >> "$target"
            fi
            pending_block=""
            continue
        fi

        pending_block=""
    done < "$template"

    if [ "$appended" -eq 1 ]; then
        echo "# ${GREEN}Added missing sirenv config options to $target.${NC}"
    else
        echo "# ${GREEN}$target already has all sirenv config options.${NC}"
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
sudo apt-get install -y git curl btop tmux jq figlet fzf wget screen zoxide bat dysk neovim build-essential

echo "# ${GREEN} sirenv shared env... ${NC}"
ensure_sirenv_env

mkdir -p ~/.local/bin
ensure_symlink "/usr/bin/batcat" "$HOME/.local/bin/bat"


echo ${GREEN}
figlet "Lets Go!"
echo "----------------"
"$SCRIPT_DIR/install/fish.sh"
"$SCRIPT_DIR/install/neovim.sh"
"$SCRIPT_DIR/install/lazygit.sh"
"$SCRIPT_DIR/install/fzf.sh"
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
        echo "$nvim_path is a directory, moving it out of the way"
        backup_dir_once "$nvim_path"
        ensure_symlink "$sir_nvim_path" "$nvim_path"
    else
        echo "i don't know what the path is?"
    fi
else
    ensure_symlink "$sir_nvim_path" "$nvim_path"
fi
echo "# ${GREEN} Checking bashrc... ${NC}"
source_line="source $sir_bashrc_path"

if grep -Fxq "$source_line" "$bashrc_path"; then
    echo "Line already present in .bashrc"
else
    echo "$source_line" >> "$bashrc_path"
    echo "Line added to .bashrc"
fi

echo "# ${GREEN} tmux... ${NC}"
ensure_symlink "$sir_tmux_path" "$config_path/tmux"


echo "# ${GREEN} Misc Dirs... ${NC}"
mkdir -p "$HOME/workbox"
mkdir -p "$HOME/sandbox"
echo "done"

mkdir -p "$HOME/bin"
ensure_symlink "$sir_ill_path" "$HOME/bin/ill"
ensure_symlink "$sir_yazi_path" "$HOME/bin/yazi"
ensure_symlink "$sir_archive" "$HOME/.local/bin/archive"
ensure_symlink "$sir_wezterm" "$wezterm_path"

echo "${YELLOW} Done for now... ${NC}"
