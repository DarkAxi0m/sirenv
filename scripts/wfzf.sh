#!/bin/bash

session_exists() {
  tmux has-session -t "$1" 2>/dev/null
}

area=$(echo -e "Work\nSandbox\nSiREnv" | fzf)

case "$area" in
  Work)
    selected_folder="/$(find ~/workbox/ -maxdepth 1 -type d | sed "s|$1/||" | fzf)"
    ;;
  Sandbox)
    selected_folder="/$(find ~/sandbox/ -maxdepth 1 -type d -exec stat --format="%Y %n" {} \; | sort -n | cut -d ' ' -f 2- | sed "s|$1/||" | fzf)"

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

if session_exists "$session_name"; then
    echo "Session '$session_name' already exists."
else
  tmux new-session -d -c "$selected_folder" -s "$session_name"



    if [ -f "$selected_folder/init.sh" ]; then
       mv "$selected_folder/init.sh" "$selected_folder/.init.sh"
    fi
    
     if [ ! -f "$selected_folder/.init.sh" ]; then
        echo "#!/bin/bash" > "$selected_folder/.init.sh"
        chmod +x "$selected_folder/.init.sh"
    
       echo "figlet -w \$(tput cols) -c \"$session_name\"" >> "$selected_folder/.init.sh"
        chmod +x "$selected_folder/init.sh"
    fi
    tmux send-keys -t $session_name "./.init.sh" C-m

fi

# Attach or switch to the tmux session
if [ -n "$TMUX" ]; then
    echo "Switching to session $session_name"
    tmux switch-client -t "$session_name"
else
    echo "Attaching to session $session_name"
    tmux attach-session -t "$session_name"
fi

