#!/bin/bash

STATE_FILE="$HOME/.waybar_notification_state"

# Load previous state
if [[ -f "$STATE_FILE" ]]; then
  popup_visible=$(<"$STATE_FILE")
else
  popup_visible=false
fi

# Toggle state 
if $popup_visible; then
  popup_visible=false
  makoctl dismiss -a
else
  popup_visible=true
  count=$(makoctl history | grep -c '^Notification [0-9]\+:')
  for i in $(seq 1 $count); do
    makoctl restore
  done
fi

# Save state
echo "$popup_visible" > "$STATE_FILE"
