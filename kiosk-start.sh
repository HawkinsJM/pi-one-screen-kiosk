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

# Apply rotation from kiosk.conf
mapfile -t OUTPUTS < <(xrandr | awk '/ connected/ {print $1}')
[[ -n "${OUTPUTS[0]}" ]] && xrandr --output "${OUTPUTS[0]}" --rotate "${DISPLAY1_ROTATE:-normal}"

# Give xrandr a moment to apply
sleep 1

# Re-read output after rotation
mapfile -t OUTPUTS < <(xrandr | awk '/ connected/ {print $1}')

# Detect resolution of the display
OUTPUT="${OUTPUTS[0]:-HDMI-1}"
W=$(xrandr | grep "^${OUTPUT} connected" | grep -oP '\d+x\d+' | head -1 | cut -dx -f1)
H=$(xrandr | grep "^${OUTPUT} connected" | grep -oP '\d+x\d+' | head -1 | cut -dx -f2)
W=${W:-1920}; H=${H:-1080}

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
