#!/usr/bin/env bash

# Bluetooth Profile Toggle ON (Switch to Handsfree/Call mode)
CARD="bluez_card.88_C9_E8_DC_ED_8E"

# Check if headphones are connected
if ! bluetoothctl info 88:C9:E8:DC:ED:8E | grep -q "Connected: yes"; then
    notify-send "Bluetooth" "Sony WH-1000XM5 not connected" -i audio-headset
    exit 1
fi

# Switch to Handsfree (Call) mode
pactl set-card-profile "$CARD" handsfree_head_unit
# Set default sink and source for calls
pactl set-default-sink "bluez_sink.88_C9_E8_DC_ED_8E.handsfree_head_unit"
pactl set-default-source "bluez_source.88_C9_E8_DC_ED_8E.handsfree_head_unit"
notify-send "Sony WH-1000XM5" "Switched to 📞 Call mode (Handsfree)" -i audio-headset
