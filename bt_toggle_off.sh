#!/usr/bin/env bash

# Bluetooth Profile Toggle OFF (Switch to A2DP/Music mode)
CARD="bluez_card.88_C9_E8_DC_ED_8E"

# Check if headphones are connected
if ! bluetoothctl info 88:C9:E8:DC:ED:8E | grep -q "Connected: yes"; then
    notify-send "Bluetooth" "Sony WH-1000XM5 not connected" -i audio-headset
    exit 1
fi

# Switch to A2DP (Music) mode
pactl set-card-profile "$CARD" a2dp_sink
# Set default sink for music
pactl set-default-sink "bluez_sink.88_C9_E8_DC_ED_8E.a2dp_sink"
notify-send "Sony WH-1000XM5" "Switched to 🎧 Music mode (A2DP)" -i audio-headphones
