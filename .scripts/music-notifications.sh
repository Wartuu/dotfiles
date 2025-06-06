#!/bin/bash
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

prev=""
id_file="/tmp/music_notify_id"

# Make sure ID file exists
[ -f "$id_file" ] || echo 0 > "$id_file"

playerctl metadata --format '{{ artist }} - {{ title }}' --follow | while read -r song; do
  if [ -z "$song" ] || [ "$song" = "$prev" ]; then
    continue
  fi

  monitor="DP-3"
  export MAKO_MONITOR="$monitor"

  prev_id=$(cat "$id_file")
  
  # Send notification and capture ID (replace if prev_id is set)
  if [[ "$prev_id" -gt 0 ]]; then
    new_id=$(notify-send -r "$prev_id" -p "Now Playing" "$song")
  else
    new_id=$(notify-send -p "Now Playing" "$song")
  fi

  echo "$new_id" > "$id_file"
  prev="$song"
done
