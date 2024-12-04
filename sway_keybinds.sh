#!/bin/bash

# Path to your Sway configuration file
SWAY_CONFIG="$HOME/.config/sway/config"

# Output file for the cheatsheet
CHEATSHEET="./sway_cheatsheet.txt"

# Extract keybindings and annotate
echo "Sway Keybindings Cheatsheet" > "$CHEATSHEET"
echo "===========================" >> "$CHEATSHEET"

# Match lines containing "bindsym" regardless of indentation
grep -E "^\s*bindsym" "$SWAY_CONFIG" | while read -r line; do
  # Extract the keybinding and command
  keybinding=$(echo "$line" | awk '{print $2}')
  command=$(echo "$line" | awk '{$1=$2=""; print $0}' | xargs)

  # Add to cheatsheet
  echo "$keybinding -> $command" >> "$CHEATSHEET"
done

# Notify user
notify-send "Cheatsheet generated" "Saved to $CHEATSHEET"
