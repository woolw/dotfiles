#!/bin/bash

STATE_FILE="$HOME/.waybar_notification_state"

if [[ -f "$STATE_FILE" ]]; then
  popup_visible=$(<"$STATE_FILE")

  if [[ "$popup_visible" == "true" ]]; then
      echo ''‌
      exit 0
  fi
fi

count=$(makoctl history | grep -c '^Notification [0-9]\+:' || true)
if [[ "$count" -eq 0 ]]; then
  echo ''
else
  echo $count
fi
