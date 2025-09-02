#!/bin/bash

# Audio diagnostic script for Sony Bluetooth headphones on Ubuntu 24.04 + Sway
# This script helps diagnose audio issues and provides troubleshooting steps

echo "=== Audio Configuration Diagnostic for Sony Bluetooth Headphones ==="
echo ""

# Check if PulseAudio is running
echo "1. Checking PulseAudio status..."
if pgrep -x "pulseaudio" > /dev/null; then
    echo "   ✅ PulseAudio is running"
    echo "   Process ID: $(pgrep -x pulseaudio)"
else
    echo "   ❌ PulseAudio is not running"
    echo "   Starting PulseAudio..."
    pulseaudio --start
fi

echo ""

# Check Bluetooth service
echo "2. Checking Bluetooth service..."
if systemctl is-active --quiet bluetooth; then
    echo "   ✅ Bluetooth service is active"
else
    echo "   ❌ Bluetooth service is not active"
    echo "   Starting Bluetooth service..."
    sudo systemctl start bluetooth
fi

echo ""

# Check Bluetooth devices
echo "3. Checking Bluetooth devices..."
echo "   Available Bluetooth devices:"
bluetoothctl devices | while read -r line; do
    if [[ $line =~ ^Device ]]; then
        echo "   📱 $line"
    fi
done

echo ""

# Check PulseAudio sinks
echo "4. Checking PulseAudio audio sinks..."
echo "   Available audio outputs:"
pactl list sinks short | while read -r line; do
    if [[ $line =~ bluetooth ]]; then
        echo "   🎧 $line (Bluetooth)"
    else
        echo "   🔊 $line"
    fi
done

echo ""

# Check default sink
echo "5. Checking default audio output..."
default_sink=$(pactl info | grep "Default Sink" | cut -d: -f2 | xargs)
if [[ $default_sink == *"bluetooth"* ]]; then
    echo "   ✅ Default sink is Bluetooth: $default_sink"
else
    echo "   ℹ️  Default sink is: $default_sink"
    echo "   To switch to Bluetooth, use: pactl set-default-sink <bluetooth_sink_name>"
fi

echo ""

# Check audio modules
echo "6. Checking loaded PulseAudio modules..."
echo "   Bluetooth modules:"
pactl list modules short | grep bluetooth || echo "   No Bluetooth modules loaded"

echo ""

# Check audio quality settings
echo "7. Checking current audio quality settings..."
echo "   Sample rate: $(pactl list sinks | grep -A 10 "State: RUNNING" | grep "Sample spec" | head -1 | cut -d: -f2 | xargs)"
echo "   Channel count: $(pactl list sinks | grep -A 10 "State: RUNNING" | grep "Channel count" | head -1 | cut -d: -f2 | xargs)"

echo ""

# Check for common issues
echo "8. Common issues and solutions:"
echo "   🔍 If audio is choppy:"
echo "      - Check Bluetooth signal strength"
echo "      - Try moving closer to the computer"
echo "      - Restart Bluetooth: sudo systemctl restart bluetooth"
echo ""
echo "   🔍 If no audio output:"
echo "      - Check volume: pactl list sinks | grep -A 10 'State: RUNNING'"
echo "      - Verify device is connected: bluetoothctl info <device_mac>"
echo "      - Restart PulseAudio: pulseaudio --kill && pulseaudio --start"
echo ""
echo "   🔍 If audio quality is poor:"
echo "      - Check codec: pactl list cards | grep -A 20 bluetooth"
echo "      - Ensure aptX/aptX HD is supported if available"
echo "      - Check for interference from other devices"

echo ""

# Show useful commands
echo "9. Useful commands:"
echo "   📊 Audio info: pactl list sinks"
echo "   🎵 Volume control: pactl set-sink-volume @DEFAULT_SINK@ 50%"
echo "   🔇 Mute toggle: pactl set-sink-mute @DEFAULT_SINK@ toggle"
echo "   🔄 Switch sink: pactl set-default-sink <sink_name>"
echo "   📱 Bluetooth control: bluetoothctl"
echo "   🎛️  Audio control panel: pavucontrol"

echo ""
echo "=== Diagnostic complete ==="
echo ""
echo "If you're still having issues, try:"
echo "1. Restarting your Sway session"
echo "2. Running: pulseaudio --kill && pulseaudio --start"
echo "3. Checking: journalctl -u bluetooth -f"
echo "4. Checking: journalctl --user -u pulseaudio -f"
