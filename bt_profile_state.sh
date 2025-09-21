#!/usr/bin/env bash

# Bluetooth Profile State Detection Script
# Returns empty output for A2DP (off), non-empty for Handsfree (on)

CARD="bluez_card.88_C9_E8_DC_ED_8E"

# Check if headphones are connected
if ! bluetoothctl info 88:C9:E8:DC:ED:8E | grep -q "Connected: yes"; then
    exit 0
fi

# Get current profile
CURRENT=$(pactl list cards | awk -v card="$CARD" '
    $0 ~ "Card #" {in_card=0}
    $0 ~ card {in_card=1}
    in_card && /Active Profile/ {print $3}')

# Return non-empty output if in handsfree mode (toggle "on")
if [ "$CURRENT" = "handsfree_head_unit" ]; then
    echo "on"
fi
