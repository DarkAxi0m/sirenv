#!/bin/bash
terminalWidth=800
terminalHeight=600

SCRIPT_DIR="$(dirname "$0")"
SCRIPT_INDEX="$SCRIPT_DIR/index.ts"

CMD="/home/chris/sirenv/illdo/ill.sh s"
UNIQUE_TITLE="Ill-$(date +%s)"

gnome-terminal --title="$UNIQUE_TITLE" --command="$CMD" &
TERMINAL_PID=$!
sleep 1
WINDOW_ID=$(wmctrl -l | grep "$UNIQUE_TITLE" | awk '{print $1}')

if [ ! -z "$WINDOW_ID" ]; then
    screenWidth=4920 #$(xrandr | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f 1)
    screenHeight=2160 #$(xrandr | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f 2)

    posX=$(( (screenWidth / 2) - (terminalWidth / 2) ))
    posY=$(( (screenHeight / 2) - (terminalHeight / 2) ))

   # wmctrl -i -r "$WINDOW_ID" -e 0,$posX,$posY,$terminalWidth,$terminalHeight
    wmctrl -i -r "$WINDOW_ID" -b add,above
else
    echo "Could not find the window ID for the terminal,  $UNIQUE_TITLE"
    read -n 1 -s -r -p "Press any key to continue"
fi












