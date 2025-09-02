# Audio Setup Guide for Sony Bluetooth Headphones on Ubuntu 24.04 + Sway

## Overview
This guide provides optimized audio configuration for Sony Bluetooth headphones on Ubuntu 24.04 with Sway window manager. The setup includes PulseAudio optimization, Bluetooth configuration, and troubleshooting steps.

## Prerequisites
- Ubuntu 24.04
- Sway window manager
- Sony Bluetooth headphones
- Bluetooth adapter (built-in or USB)

## Current Setup Analysis
Your system already has:
- ✅ PulseAudio with Bluetooth module
- ✅ Bluetooth stack (bluez, blueman)
- ✅ Audio utilities (pavucontrol, alsa-utils, playerctl)
- ✅ Hardware key bindings for volume control
- ✅ Bluetooth applet (blueman-applet) in Sway

## Step 1: Run Audio Configuration Script
Execute the PulseAudio configuration script to optimize settings for your Sony headphones:

```bash
./pulseaudio_config.sh
```

This script creates:
- `~/.config/pulse/daemon.conf` - Optimized daemon settings
- `~/.config/pulse/client.conf` - Client configuration
- `~/.config/pulse/default.pa` - Module loading configuration
- `~/.config/pulse/system.pa` - System-wide settings

## Step 2: Restart Audio Services
After running the configuration script, restart PulseAudio:

```bash
# Kill current PulseAudio instance
pulseaudio --kill

# Start with new configuration
pulseaudio --start

# Or restart your Sway session for full effect
```

## Step 3: Connect Sony Headphones
1. **Enable Bluetooth** (if not already enabled):
   ```bash
   sudo systemctl start bluetooth
   sudo systemctl enable bluetooth
   ```

2. **Put headphones in pairing mode** (refer to Sony manual)

3. **Scan and pair**:
   ```bash
   bluetoothctl
   scan on
   # Look for your Sony device
   pair <MAC_ADDRESS>
   connect <MAC_ADDRESS>
   trust <MAC_ADDRESS>
   ```

4. **Verify connection**:
   ```bash
   bluetoothctl devices
   bluetoothctl info <MAC_ADDRESS>
   ```

## Step 4: Configure Audio Output
1. **Check available sinks**:
   ```bash
   pactl list sinks short
   ```

2. **Set Bluetooth as default** (replace with your actual sink name):
   ```bash
   pactl set-default-sink bluez_sink.XX_XX_XX_XX_XX_XX
   ```

3. **Verify default sink**:
   ```bash
   pactl info | grep "Default Sink"
   ```

## Step 5: Test and Optimize
1. **Play test audio**:
   ```bash
   # Test with a simple tone
   speaker-test -t sine -f 1000 -l 1

   # Or test with music/video
   ```

2. **Check audio quality**:
   ```bash
   pactl list sinks | grep -A 10 "State: RUNNING"
   ```

3. **Adjust volume**:
   ```bash
   # Set to 50%
   pactl set-sink-volume @DEFAULT_SINK@ 50%

   # Or use hardware keys (already configured in Sway)
   ```

## Step 6: Run Diagnostic Script
Use the diagnostic script to check your setup:

```bash
./check_audio.sh
```

This will:
- Verify PulseAudio status
- Check Bluetooth service
- List available devices
- Show audio sinks
- Identify common issues
- Provide troubleshooting steps

## Troubleshooting Common Issues

### No Audio Output
1. **Check device connection**:
   ```bash
   bluetoothctl info <MAC_ADDRESS>
   ```

2. **Verify audio sink**:
   ```bash
   pactl list sinks | grep -A 10 bluetooth
   ```

3. **Check volume levels**:
   ```bash
   pactl list sinks | grep -A 10 "State: RUNNING"
   ```

4. **Restart services**:
   ```bash
   sudo systemctl restart bluetooth
   pulseaudio --kill && pulseaudio --start
   ```

### Poor Audio Quality
1. **Check codec support**:
   ```bash
   pactl list cards | grep -A 20 bluetooth
   ```

2. **Verify sample rate**:
   ```bash
   pactl list sinks | grep "Sample spec"
   ```

3. **Check for interference**:
   - Move closer to computer
   - Remove other Bluetooth devices
   - Check WiFi channel conflicts

### Audio Dropouts/Choppy Sound
1. **Check signal strength**:
   ```bash
   bluetoothctl info <MAC_ADDRESS> | grep RSSI
   ```

2. **Reduce buffer size** (edit `~/.config/pulse/daemon.conf`):
   ```ini
   default-fragment-size-msec = 20
   default-fragments = 3
   ```

3. **Enable power management** (edit `~/.config/pulse/daemon.conf`):
   ```ini
   flat-volumes = no
   ```

## Advanced Configuration

### Enable aptX/aptX HD (if supported)
1. **Check codec support**:
   ```bash
   pactl list cards | grep -A 30 bluetooth
   ```

2. **Force codec** (if available):
   ```bash
   # For aptX
   pactl set-card-profile <card_name> a2dp-sink-aptx

   # For aptX HD
   pactl set-card-profile <card_name> a2dp-sink-aptx-hd
   ```

### Custom Equalizer
1. **Install equalizer**:
   ```bash
   sudo apt install pulseaudio-equalizer
   ```

2. **Load equalizer module**:
   ```bash
   pactl load-module module-equalizer-sink sink_name=equalized_sink
   ```

3. **Set as default**:
   ```bash
   pactl set-default-sink equalized_sink
   ```

## Useful Commands Reference

### Audio Control
```bash
# Volume control
pactl set-sink-volume @DEFAULT_SINK@ +5%    # Increase 5%
pactl set-sink-volume @DEFAULT_SINK@ -5%    # Decrease 5%
pactl set-sink-volume @DEFAULT_SINK@ 50%    # Set to 50%

# Mute control
pactl set-sink-mute @DEFAULT_SINK@ toggle   # Toggle mute
pactl set-sink-mute @DEFAULT_SINK@ 0        # Unmute
pactl set-sink-mute @DEFAULT_SINK@ 1        # Mute

# Sink switching
pactl list sinks short                      # List all sinks
pactl set-default-sink <sink_name>          # Set default sink
```

### Bluetooth Control
```bash
# Device management
bluetoothctl devices                         # List paired devices
bluetoothctl info <MAC>                     # Device info
bluetoothctl connect <MAC>                  # Connect device
bluetoothctl disconnect <MAC>               # Disconnect device
bluetoothctl remove <MAC>                   # Remove device

# Service control
sudo systemctl start bluetooth              # Start service
sudo systemctl stop bluetooth               # Stop service
sudo systemctl restart bluetooth            # Restart service
```

### PulseAudio Control
```bash
# Service control
pulseaudio --start                          # Start PulseAudio
pulseaudio --kill                           # Stop PulseAudio
pulseaudio --reload                         # Reload configuration

# Information
pactl info                                  # Server information
pactl list sinks                            # List audio outputs
pactl list sources                          # List audio inputs
pactl list cards                            # List audio cards
```

## GUI Tools
- **pavucontrol**: Main audio control panel
- **blueman-manager**: Bluetooth device manager
- **blueman-applet**: System tray Bluetooth applet

## Performance Tips
1. **Keep devices close** for better signal strength
2. **Avoid 2.4GHz WiFi interference** by using 5GHz when possible
3. **Regularly restart Bluetooth** if experiencing issues
4. **Monitor battery levels** on headphones
5. **Use wired connection** for critical audio applications

## Support
If you continue experiencing issues:
1. Check system logs: `journalctl -u bluetooth -f`
2. Check PulseAudio logs: `journalctl --user -u pulseaudio -f`
3. Verify hardware compatibility
4. Consider updating Bluetooth firmware

## Files Created
- `pulseaudio_config.sh` - Configuration script
- `check_audio.sh` - Diagnostic script
- `~/.config/pulse/` - PulseAudio configuration directory
- `AUDIO_SETUP.md` - This guide

Your audio setup should now be optimized for Sony Bluetooth headphones with improved quality and reliability!
