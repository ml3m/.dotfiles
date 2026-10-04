#!/bin/bash
# Omarchy bar auto-hide daemon
# Hides the bar when the cursor leaves the top edge, shows it when the cursor
# returns to the very top. Uses Omarchy's native bar-off toggle flag so the
# Quickshell bar animates itself in/out.

SHOW_ZONE=2       # px from top edge to trigger show
HIDE_ZONE=36      # px below which cursor must drop to trigger hide
HIDE_DELAY=0.1    # seconds to wait before hiding after cursor leaves
POLL_INTERVAL=0.1 # seconds between cursor checks

FLAG="$HOME/.local/state/omarchy/toggles/bar-off"

bar_is_hidden() { [[ -f "$FLAG" ]]; }

show_bar() {
    if bar_is_hidden; then
        rm -f "$FLAG"
    fi
}

hide_bar() {
    if ! bar_is_hidden; then
        mkdir -p "$(dirname "$FLAG")"
        touch "$FLAG"
    fi
}

# Resolve the Y coordinate relative to the focused monitor's top edge.
# hyprctl cursorpos gives absolute coords; we need monitor-local Y.
cursor_local_y() {
    local pos mon
    pos=$(hyprctl cursorpos 2>/dev/null) || return 1
    mon=$(hyprctl monitors -j 2>/dev/null) || return 1

    # Parse absolute cursor position
    local cx cy
    cx=${pos%%,*}
    cy=${pos##*, }
    cx=${cx// /}
    cy=${cy// /}

    # Find which monitor the cursor is on and compute local Y
    python3 -c "
import json, sys
cx, cy = int(sys.argv[1]), int(sys.argv[2])
monitors = json.loads(sys.argv[3])
for m in monitors:
    mx, my = m['x'], m['y']
    # Use transform-aware dimensions
    mw = int(m['width'] / m['scale'])
    mh = int(m['height'] / m['scale'])
    if mx <= cx < mx + mw and my <= cy < my + mh:
        print(cy - my)
        sys.exit(0)
# Fallback: use raw Y
print(cy)
" "$cx" "$cy" "$mon"
}

# --- Main loop ---

# Kill any previous instance of this script (except ourselves)
for pid in $(pgrep -f "bar-autohide\.sh" 2>/dev/null); do
    if [[ "$pid" != "$$" ]]; then
        kill "$pid" 2>/dev/null
    fi
done

# Start with bar hidden
hide_bar

hide_pending=false
hide_timestamp=0

while true; do
    local_y=$(cursor_local_y 2>/dev/null)

    if [[ -z "$local_y" ]]; then
        sleep "$POLL_INTERVAL"
        continue
    fi

    if ((local_y <= SHOW_ZONE)); then
        # Cursor at the top edge — show immediately
        show_bar
        hide_pending=false
    elif ((local_y > HIDE_ZONE)); then
        # Cursor below the bar area
        if ! bar_is_hidden; then
            if [[ "$hide_pending" == false ]]; then
                # Start hide countdown
                hide_pending=true
                hide_timestamp=$(date +%s%N)
            else
                # Check if delay has elapsed
                now=$(date +%s%N)
                elapsed=$(((now - hide_timestamp) / 1000000)) # ms
                delay_ms=$(python3 -c "print(int($HIDE_DELAY * 1000))")
                if ((elapsed >= delay_ms)); then
                    hide_bar
                    hide_pending=false
                fi
            fi
        fi
    else
        # Cursor in the bar zone (between SHOW_ZONE and HIDE_ZONE) — keep current state, cancel any pending hide
        hide_pending=false
    fi

    sleep "$POLL_INTERVAL"
done
