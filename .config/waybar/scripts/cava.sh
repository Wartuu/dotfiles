#!/bin/bash

# Configurable parameters
BARS=20
BAR_SYMBOLS=( ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ )
MAX_VAL=9

CONFIG="/tmp/waybar_cava_config"

# Generate cava config file dynamically
cat > "$CONFIG" <<EOF
[general]
bars = $BARS
sleep_timer = 1

[input]
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = $MAX_VAL
EOF

# Start cava with the generated config, parse output live
cava -p "$CONFIG" | while read -r line; do
    # line example: "0123456789" (each digit corresponds to a bar level 0..MAX_VAL)
    out=""
    for ((i=0; i<BARS; i++)); do
        char="${line:i:1}"
        if [[ "$char" =~ [0-9] ]]; then
            val=$((char))
            # Map val (0-$MAX_VAL) to symbol index (0 to length(BAR_SYMBOLS)-1)
            idx=$(( val * (${#BAR_SYMBOLS[@]} - 1) / MAX_VAL ))
            out+="${BAR_SYMBOLS[$idx]}"
        else
            out+=""
        fi
    done

    song=$(playerctl metadata --format '{{ artist }} - {{ title }}')
    echo "{\"text\": \"$out\", \"tooltip\": \"$song\"}"
done
