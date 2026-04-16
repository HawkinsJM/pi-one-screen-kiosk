#!/bin/bash
# kiosk-start.sh — runs inside the X session (called by xinit)
# Reads kiosk.conf and launches a single Chromium window on the first HDMI output.

set -e

source /home/jeff/kiosk.conf

# Disable screen blanking and power management
xset s off
xset s noblank
xset -dpms

# Hide mouse cursor after 0.5 s idle
unclutter -idle 0.5 -root &

# Start the window manager (needed to honour window position)
openbox --no-config &
sleep 2

# Auto-detect and enable connected output
xrandr --auto

# Pi 4 HDMI hotplug detection bug: HDMI-1 may show as disconnected even when active.
# Force a mode on HDMI-1 if no outputs are detected as connected.
if ! xrandr | grep -q " connected"; then
    xrandr --newmode "1920x1080_60" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync 2>/dev/null || true
    xrandr --addmode HDMI-1 "1920x1080_60" 2>/dev/null || true
    xrandr --output HDMI-1 --mode "1920x1080_60"
fi

# Determine active output (prefer connected, fall back to HDMI-1 for hotplug bug)
OUTPUT=$(xrandr | awk '/ connected/ {print $1; exit}')
OUTPUT="${OUTPUT:-HDMI-1}"

# Apply rotation from kiosk.conf
xrandr --output "${OUTPUT}" --rotate "${DISPLAY1_ROTATE:-normal}"

# Give xrandr a moment to apply
sleep 1

# Get screen dimensions from Screen 0 (reflects post-rotation size)
read -r W H < <(xrandr | awk '/^Screen 0:.*current/ {
    for (i=1;i<=NF;i++) if ($i=="current") { print $(i+1), $(i+3); break }
}' | tr -d ',')

chromium \
    --app="http://localhost/${DISPLAY1_SITE}" \
    --user-data-dir=/tmp/kiosk-display1 \
    --window-position="0,0" \
    --window-size="${W},${H}" \
    --kiosk \
    --no-first-run \
    --noerrdialogs \
    --disable-infobars \
    --disable-session-crashed-bubble \
    --disable-translate \
    --disable-features=TranslateUI \
    --autoplay-policy=no-user-gesture-required

wait
