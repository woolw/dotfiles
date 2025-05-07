#!/bin/bash

CONFIG_DIR="$HOME/.config/waybar"

while inotifywait -e close_write,moved_to,create "$CONFIG_DIR"; do
    killall waybar
    waybar &
done
