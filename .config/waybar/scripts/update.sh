#!/bin/bash

updates=$(checkupdates 2>/dev/null)
count=$(echo "$updates" | grep -c '^[^[:space:]]')


if [[ $count -eq 0 ]]; then
    echo '{"text": " ", "tooltip": "System is up to date!"}'
else
    tooltip=$(echo "$updates" | sed ':a;N;$!ba;s/\n/\\n/g')
    echo "{\"text\": \"$count 󰚰 \", \"tooltip\": \"$tooltip\"}"
fi
