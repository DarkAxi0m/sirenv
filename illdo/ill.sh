#!/bin/bash
link_dir="$(dirname "$(readlink -f "$0")")"

helpguid() {
    echo "Usage: $0 <do>"
    echo 
    echo "Do Options:"
    sh_files=$(ls "$link_dir"/*.sh | grep -v "ill.sh")

    for file_path in $sh_files; do
        file_name=$(basename "$file_path" .sh)
        echo "* $file_name"
    done
    echo
exit 1
}

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    helpguid
fi


param1=$1

if [ "$param1" = "s" ]; then
    param1=$(ls "$link_dir"/*.sh | grep -Ev "(ill.sh|install.sh)" | xargs -n 1 basename -s .sh | fzf)
fi


firsttest="$link_dir/$param1.sh"


if [ -e "$firsttest" ]; then
   figlet " $param1"
   source "$firsttest" 
   exit 1
fi


helpguid

