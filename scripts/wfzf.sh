#!/bin/bash

session_exists() {
  local session_name="$1"
  tmux has-session -t "$session_name" 2>/dev/null
}

area=$(echo -e "Work\nSandbox\nSiREnv" | fzf)

case "$area" in
  Work)
    selected_folder=$(find ~/workbox/ -maxdepth 1 -type d | sed "s|$1/||" | fzf)
    ;;
  Sandbox)
#    selected_folder=$(find ~/sandbox/ -maxdepth 1 -type d | sed "s|$1/||" | fzf)
#selected_folder=$(find ~/sandbox/ -maxdepth 1 -type d -exec stat --format="%Y %n" {} \; | sort -nr | cut -d ' ' -f 2- | sed "s|$1/||" | fzf)
selected_folder=$(find ~/sandbox/ -maxdepth 1 -type d -exec stat --format="%Y %n" {} \; | sort -n | cut -d ' ' -f 2- | sed "s|$1/||" | fzf)

;;
  SiREnv)
    selected_folder="/home/chris/sirenv"
    ;;
  *)
    ;;
esac

if [ -z "$selected_folder" ]; then
  echo "No folder selected. Exiting."
  exit 1
fi

selected_path="$1/$selected_folder"
session_name=$(basename "$selected_folder")

if session_exists "$session_name"; then
  tmux attach-session -t "$session_name"
else
  selected_path="$1/$selected_folder"
  echo
  echo
  figlet -w $(tput cols) -c "$session_name"
  echo
  if [ -d "$selected_path" ] && [ -f "$selected_path/init.sh" ]; then
    cd "$selected_path" && ./init.sh
  fi
  tmux new-session -c "$selected_path" -s "$session_name"
fi

