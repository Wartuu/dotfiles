#!/bin/bash

interface=$(ip route | awk '/default/ {print $5}')
local_ip=$(ip addr show "$interface" | awk '/inet / {print $2}' | cut -d/ -f1)

rx_prev=$(cat /sys/class/net/$interface/statistics/rx_bytes)
tx_prev=$(cat /sys/class/net/$interface/statistics/tx_bytes)
sleep 1
rx_next=$(cat /sys/class/net/$interface/statistics/rx_bytes)
tx_next=$(cat /sys/class/net/$interface/statistics/tx_bytes)

rx_rate_mbps=$(awk "BEGIN {printf \"%.2f\", ($rx_next - $rx_prev) / 1024 / 1024}")
tx_rate_mbps=$(awk "BEGIN {printf \"%.2f\", ($tx_next - $tx_prev) / 1024 / 1024}")

cache_file="/tmp/public_ip.cache"
cache_age=3600

if [[ -f "$cache_file" && $(($(date +%s) - $(stat -c %Y "$cache_file"))) -lt $cache_age ]]; then
    public_ip=$(cat "$cache_file")
else
    public_ip=$(curl -s https://ipinfo.io/ip)
    echo "$public_ip" > "$cache_file"
fi

echo "{\"text\":\" ${rx_rate_mbps}MB/s  ${tx_rate_mbps}MB/s\", \"tooltip\":\"Local IP: $local_ip\nPublic IP: $public_ip\"}"
