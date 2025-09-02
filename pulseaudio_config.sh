#!/bin/bash

# PulseAudio configuration for Sony Bluetooth headphones on Ubuntu 24.04 + Sway
# This script optimizes audio settings for better Bluetooth audio quality

echo "Configuring PulseAudio for Sony Bluetooth headphones..."

# Create PulseAudio config directory if it doesn't exist
mkdir -p "$HOME/.config/pulse"

# Create daemon.conf with optimized settings for Bluetooth
cat > "$HOME/.config/pulse/daemon.conf" << 'EOF'
# PulseAudio daemon configuration for Sony Bluetooth headphones
# Optimized for Ubuntu 24.04 + Sway

# General settings
daemonize = yes
allow-module-loading = yes
allow-exit = yes
use-pid-file = yes

# Audio quality settings
default-sample-format = s16le
default-sample-rate = 48000
alternate-sample-rate = 44100
default-sample-channels = 2
default-channel-map = front-left,front-right

# Buffer settings for Bluetooth
default-fragments = 4
default-fragment-size-msec = 25

# Resampling quality
resample-method = speex-float-5
avoid-resampling = yes

# Bluetooth specific optimizations
enable-remixing = yes
remixing-use-all-sink-channels = yes
remixing-produce-lfe = no
remixing-consume-lfe = no

# Network settings (if using network audio)
disallow-module-loading = no

# Logging
log-level = 4
log-target = auto
EOF

# Create client.conf with user-specific settings
cat > "$HOME/.config/pulse/client.conf" << 'EOF'
# PulseAudio client configuration
# Optimized for Sony Bluetooth headphones

# Auto-restart PulseAudio if it crashes
autospawn = yes
daemon-binary = /usr/bin/pulseaudio
enable-shm = yes
shm-size-bytes = 0
EOF

# Create default.pa with Bluetooth optimizations
cat > "$HOME/.config/pulse/default.pa" << 'EOF'
#!/usr/bin/pulseaudio -nF
#
# This file is part of PulseAudio.
#
# PulseAudio is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# PulseAudio is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with PulseAudio; if not, see <http://www.gnu.org/licenses/>.

# This startup script is used when PulseAudio is started in system
# mode.

### Load core protocols modules
load-module module-native-protocol-unix socket=/tmp/pulse-socket auth-anonymous=1

### Make sure we always have a sink/source, even if hardware detection fails
load-module module-null-sink sink_name=null sink_properties=device.description="Dummy Output"
load-module module-null-source source_name=null source_properties=device.description="Dummy Input"

### Enable positioned event sounds
load-module module-position-event-sounds

### Load Bluetooth modules with optimizations
load-module module-bluetooth-discover
load-module module-bluetooth-policy

### Load audio processing modules
load-module module-udev-detect
load-module module-detect
load-module module-suspend-on-idle

### Load volume control
load-module module-volume-restore

### Load stream routing
load-module module-stream-restore
load-module module-default-device-restore

### Load card policy
load-module module-card-restore

### Load Bluetooth audio with Sony optimizations
load-module module-bluetooth-policy auto_switch=1
load-module module-bluetooth-discover headset=auto

### Load audio processing for better quality
load-module module-equalizer-sink
load-module module-switch-on-connect

### Load protocol modules
load-module module-native-protocol-tcp auth-anonymous=1
load-module module-native-protocol-unix auth-anonymous=1

### Load restore modules
load-module module-stream-restore restore_device=false
load-module module-device-restore restore_device=false
load-module module-card-restore restore_device=false
load-module module-default-device-restore restore_device=false
load-module module-volume-restore restore_device=false
EOF

# Create system.pa with system-wide settings
cat > "$HOME/.config/pulse/system.pa" << 'EOF'
#!/usr/bin/pulseaudio -nF
#
# This file is part of PulseAudio.
#
# PulseAudio is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# PulseAudio is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with PulseAudio; if not, see <http://www.gnu.org/licenses/>.

# This startup script is used when PulseAudio is started in system
# mode.

### Load core protocols modules
load-module module-native-protocol-unix socket=/tmp/pulse-socket auth-anonymous=1

### Make sure we always have a sink/source, even if hardware detection fails
load-module module-null-sink sink_name=null sink_properties=device.description="Dummy Output"
load-module module-null-source source_name=null source_properties=device.description="Dummy Input"

### Enable positioned event sounds
load-module module-position-event-sounds

### Load Bluetooth modules
load-module module-bluetooth-discover
load-module module-bluetooth-policy

### Load audio processing modules
load-module module-udev-detect
load-module module-detect
load-module module-suspend-on-idle

### Load volume control
load-module module-volume-restore

### Load stream routing
load-module module-stream-restore
load-module module-default-device-restore

### Load card policy
load-module module-card-restore

### Load Bluetooth audio
load-module module-bluetooth-policy auto_switch=1
load-module module-bluetooth-discover headset=auto

### Load audio processing
load-module module-equalizer-sink
load-module module-switch-on-connect

### Load protocol modules
load-module module-native-protocol-tcp auth-anonymous=1
load-module module-native-protocol-unix auth-anonymous=1

### Load restore modules
load-module module-stream-restore restore_device=false
load-module module-device-restore restore_device=false
load-module module-card-restore restore_device=false
load-module module-default-device-restore restore_device=false
load-module module-volume-restore restore_device=false
EOF

# Set proper permissions
chmod 644 "$HOME/.config/pulse"/*.conf
chmod 644 "$HOME/.config/pulse"/*.pa

echo "PulseAudio configuration created successfully!"
echo "Restart PulseAudio to apply changes:"
echo "  pulseaudio --kill && pulseaudio --start"
echo ""
echo "Or restart your Sway session for full effect."
