#!/bin/bash

teamsstatus.sh BeRightBack &
xdotool key XF86AudioPlay &
amixer set Master mute &
gsettings set org.gnome.desktop.background picture-uri-dark file:///home/chris/Pictures/Wallpapers/wallpaperflare.com_wallpaper2.jpg &

wait


# Check if the gnome-screensaver-command or xdg-screensaver command is available
if command -v gnome-screensaver-command &> /dev/null; then
    gnome-screensaver-command -l
elif command -v xdg-screensaver &> /dev/null; then
    xdg-screensaver lock
else
    echo "Screen locking command not found. Please install gnome-screensaver or xdg-utils."
    exit 1
fi
