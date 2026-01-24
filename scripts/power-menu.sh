#!/bin/sh
# macOS-style power menu using fuzzel

options="󰌾  Lock
󰤄  Sleep
󰜉  Restart
󰐥  Shut Down
󰍃  Log Out"

selected=$(echo "$options" | fuzzel --dmenu \
    --prompt "" \
    --width 14 \
    --lines 5 \
    --anchor top-left \
    --x-margin 8 \
    --y-margin 36)

case "$selected" in
    "󰌾  Lock")
        hyprlock
        ;;
    "󰤄  Sleep")
        systemctl suspend
        ;;
    "󰜉  Restart")
        systemctl reboot
        ;;
    "󰐥  Shut Down")
        systemctl poweroff
        ;;
    "󰍃  Log Out")
        hyprctl dispatch exit
        ;;
esac
