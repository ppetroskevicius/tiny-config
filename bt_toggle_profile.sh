#!/usr/bin/env bash

# Bluetooth Profile Toggle Script for Sony WH-1000XM5
# Toggles between A2DP (music) and Handsfree (calls) profiles

CARD="bluez_card.88_C9_E8_DC_ED_8E"

# Check if headphones are connected
if ! bluetoothctl info 88:C9:E8:DC:ED:8E | grep -q "Connected: yes"; then
    notify-send "Bluetooth" "Sony WH-1000XM5 not connected" -i audio-headset
    exit 1
fi

# Get current profile
CURRENT=$(pactl list cards | awk -v card="$CARD" '
    $0 ~ "Card #" {in_card=0}
    $0 ~ card {in_card=1}
    in_card && /Active Profile/ {print $3}')

if [ "$CURRENT" = "a2dp_sink" ]; then
    # Switch to Handsfree (Call) mode
    pactl set-card-profile "$CARD" handsfree_head_unit
    # Set default sink and source for calls
    pactl set-default-sink "bluez_sink.88_C9_E8_DC_ED_8E.handsfree_head_unit"
    pactl set-default-source "bluez_source.88_C9_E8_DC_ED_8E.handsfree_head_unit"
    notify-send "Sony WH-1000XM5" "Switched to 📞 Call mode (Handsfree)" -i audio-headset
else
    # Switch to A2DP (Music) mode
    pactl set-card-profile "$CARD" a2dp_sink
    # Set default sink for music
    pactl set-default-sink "bluez_sink.88_C9_E8_DC_ED_8E.a2dp_sink"
    notify-send "Sony WH-1000XM5" "Switched to 🎧 Music mode (A2DP)" -i audio-headphones
fi
