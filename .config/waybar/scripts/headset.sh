#!/usr/bin/env bash

out=$(headsetcontrol -b 2>/dev/null)

json() {
    echo "{\"text\":\"$1\",\"tooltip\":\"$2\"}"
}

if [[ $? -ne 0 || -z "$out" ]]; then
    json "🎧 N/A" "SteelSeries Arctis 7+: Not connected or unavailable"
    exit 0
fi

# Check for unavailable
status=$(echo "$out" | grep -Po 'Status:\s*\K\w+')

if [[ "$status" == "BATTERY_UNAVAILABLE" ]]; then
    json "🎧 N/A" "SteelSeries Arctis 7+: Battery unavailable"
    exit 0
fi

# Battery level
percent=$(echo "$out" | grep -Po 'Level:\s*\K[0-9]+')

# Choose icon
if [[ "$status" == "BATTERY_CHARGING" ]]; then
    if (( percent < 20 )); then
        icon="󰢟"
    elif (( percent < 50 )); then
        icon="󰢜"
    elif (( percent < 80 )); then
        icon="󰢝"
    else
        icon="󰂄"
    fi
    desc="Charging"
else
    if (( percent < 20 )); then
        icon="󰤿"
    elif (( percent < 50 )); then
        icon="󰥂"
    elif (( percent < 80 )); then
        icon="󰥄"
    else
        icon="󰥉"
    fi
    desc="Not charging"
fi

json "$icon ${percent}%" "SteelSeries Arctis 7+: ${percent}%, ${desc}"
