#!/bin/bash
#

echo "Checking Ill is install"


link_path=~/bin/i
ill_path="$(pwd)/ill.sh"


if [ -e "$link_path" ]; then
   echo "The symbolic link $link_path exists."
else
   ln -s "$ill_path" "$link_path"
   echo "Ill Installed"
fi
