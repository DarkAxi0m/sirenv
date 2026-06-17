#!/bin/bash

session_exists() {
  tmux has-session -t "$1" 2>/dev/null
}

# Build list: existing sessions first, then your areas
tmux_sessions=$(tmux list-sessions -F '#S' 2>/dev/null)
choice=$(
  printf "%s\nWork\nSandbox\nSiREnv\n" "$tmux_sessions" \
  | sed '/^$/d' \
  | awk '!seen[$0]++' \
  | fzf --prompt="Session/Area > "
)

[ -z "$choice" ] && { echo "No selection. Exiting."; exit 1; }

# If selection matches an existing tmux session, just go to it
if session_exists "$choice"; then
  session_name="$choice"
  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$session_name"
  else
    tmux attach-session -t "$session_name"
  fi
  exit 0
fi

area="$choice"

case "$area" in
  Work)
    selected_folder="$(find "$HOME/workbox" -maxdepth 1 -type d | fzf)"
    ;;
  Sandbox)
    selected_folder="$(
      find "$HOME/sandbox" -maxdepth 1 -type d -exec stat --format="%Y %n" {} \; \
      | sort -n \
      | cut -d ' ' -f 2- \
      | fzf
    )"
    ;;
  SiREnv)
    selected_folder="$HOME/sirenv"
    ;;
  *)
    echo "Invalid selection. Exiting."
    exit 1
    ;;
esac

[ -z "$selected_folder" ] && { echo "No folder selected. Exiting."; exit 1; }

session_name="$(basename "$selected_folder")"

if ! session_exists "$session_name"; then
  tmux new-session -d -c "$selected_folder" -s "$session_name"

  if [ -f "$selected_folder/init.sh" ]; then
    mv "$selected_folder/init.sh" "$selected_folder/.init.sh"
  fi

  if [ ! -f "$selected_folder/.init.sh" ]; then
    {
      echo "#!/bin/bash"
      echo "figlet -w \$(tput cols) -c \"$session_name\""
    } > "$selected_folder/.init.sh"
    chmod +x "$selected_folder/.init.sh"
  fi

  tmux send-keys -t "$session_name" "./.init.sh" C-m
fi

if [ -n "$TMUX" ]; then
  tmux switch-client -t "$session_name"
else
  tmux attach-session -t "$session_name"
fi
