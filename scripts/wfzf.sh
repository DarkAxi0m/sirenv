#!/bin/bash

session_exists() {
  tmux has-session -t "$1" 2>/dev/null
}

area=$(echo -e "Work\nSandbox\nSiREnv" | fzf)

case "$area" in
  Work)
    selected_folder=$(find ~/workbox/ -maxdepth 1 -type d | fzf --with-nth=2..)
    ;;
  Sandbox)
    selected_folder=$(find ~/sandbox/ -maxdepth 1 -type d -exec stat --format="%Y %n" {} \; | sort -nr | cut -d ' ' -f 2- | fzf)
    ;;
  SiREnv)
    selected_folder="/home/chris/sirenv"
    ;;
  *)
    echo "Invalid selection. Exiting."
    exit 1
    ;;
esac

if [ -z "$selected_folder" ]; then
  echo "No folder selected. Exiting."
  exit 1
fi

session_name=$(basename "$selected_folder")
selected_path="$selected_folder" # Since selected_folder already contains the full path

if session_exists "$session_name"; then
    echo "Session '$session_name' already exists."
else
  echo -e "\n\n$(figlet -w $(tput cols) -c "$session_name")\n"

  if [ -d "$selected_path" ] && [ -f "$selected_path/init.sh" ]; then
    (cd "$selected_path" && ./init.sh)
  fi

  echo "Creating session $session_name"
  tmux new-session -d -c "$selected_path" -s "$session_name" 
fi

if [ -n "$TMUX" ]; then
    echo "Switching to session $session_name"a
    tmux switch-client -t "$session_name"
else
    echo "Attaching to session $session_name"
    tmux attach-session -t "$session_name"
fi

