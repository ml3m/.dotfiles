#!/bin/bash
SCRIPT="$HOME/.config/omarchy/bar-autohide.sh"
FLAG="$HOME/.local/state/omarchy/toggles/bar-off"

if pgrep -f "bar-autohide.sh" > /dev/null; then
    pkill -f "bar-autohide.sh"
    rm -f "$FLAG"
    notify-send -a "Omarchy" "Bar Autohide Disabled"
else
    chmod +x "$SCRIPT"
    nohup "$SCRIPT" >/dev/null 2>&1 &
    notify-send -a "Omarchy" "Bar Autohide Enabled"
fi
