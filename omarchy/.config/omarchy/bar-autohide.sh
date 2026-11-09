#!/bin/bash
""":"
# Omarchy bar auto-hide daemon
# Polyglot wrapper (Bash -> Python 3) for high performance and zero child forks.
exec python3 "$0" "$@"
"""

import os
import sys
import time
import json
import socket
import signal
import subprocess

SHOW_ZONE = 3       # px from top edge to trigger show
BAR_ZONE = 36       # px for the top bar height
HIDE_DELAY = 0.45   # seconds to wait before hiding after leaving interactive zone
MENU_TIMEOUT = 3.0  # seconds stationary in menu zone before hide countdown
POLL_INTERVAL = 0.05 # 50ms check interval

FLAG = os.path.expanduser("~/.local/state/omarchy/toggles/bar-off")

def bar_is_hidden():
    return os.path.exists(FLAG)

def show_bar():
    if bar_is_hidden():
        try:
            os.remove(FLAG)
        except OSError:
            pass

def hide_bar():
    if not bar_is_hidden():
        try:
            os.makedirs(os.path.dirname(FLAG), exist_ok=True)
            with open(FLAG, "w") as f:
                pass
        except OSError:
            pass

def kill_previous_instances():
    my_pid = os.getpid()
    parent_pid = os.getppid()
    try:
        out = subprocess.check_output(["pgrep", "-f", "bar-autohide"], text=True)
        for line in out.strip().splitlines():
            pid = int(line.strip())
            if pid != my_pid and pid != parent_pid:
                try:
                    os.kill(pid, signal.SIGTERM)
                except OSError:
                    pass
    except Exception:
        pass

def get_hypr_socket():
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    his = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if not his:
        hypr_dir = os.path.join(runtime_dir, "hypr")
        if os.path.exists(hypr_dir):
            entries = sorted(os.listdir(hypr_dir), key=lambda e: os.path.getmtime(os.path.join(hypr_dir, e)), reverse=True)
            for entry in entries:
                candidate = os.path.join(hypr_dir, entry, ".socket.sock")
                if os.path.exists(candidate):
                    return candidate
        return None
    return os.path.join(runtime_dir, "hypr", his, ".socket.sock")

class HyprClient:
    def __init__(self):
        self.sock_path = get_hypr_socket()
        self.monitors = []
        self.last_monitors_time = 0

    def cmd(self, command_str):
        if not self.sock_path or not os.path.exists(self.sock_path):
            self.sock_path = get_hypr_socket()
        if not self.sock_path:
            return ""
        try:
            s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            s.settimeout(0.2)
            s.connect(self.sock_path)
            s.sendall(command_str.encode("utf-8"))
            data = b""
            while True:
                chunk = s.recv(4096)
                if not chunk:
                    break
                data += chunk
            s.close()
            return data.decode("utf-8", errors="replace").strip()
        except Exception:
            return ""

    def get_monitors(self):
        now = time.time()
        if not self.monitors or (now - self.last_monitors_time > 5.0):
            res = self.cmd("j/monitors")
            if res:
                try:
                    self.monitors = json.loads(res)
                    self.last_monitors_time = now
                except json.JSONDecodeError:
                    pass
        return self.monitors

    def get_cursor_and_monitor(self):
        pos_raw = self.cmd("cursorpos")
        if not pos_raw or "," not in pos_raw:
            return None, None, None, None, None
        try:
            cx, cy = [int(p.strip()) for p in pos_raw.split(",")]
        except ValueError:
            return None, None, None, None, None

        monitors = self.get_monitors()
        for m in monitors:
            mx, my = m["x"], m["y"]
            scale = m.get("scale", 1.0)
            mw = int(m["width"] / scale)
            mh = int(m["height"] / scale)
            if mx <= cx < mx + mw and my <= cy < my + mh:
                lx = cx - mx
                ly = cy - my
                return lx, ly, mw, mh, m["name"]

        # If not found, refresh monitors immediately and retry
        self.last_monitors_time = 0
        monitors = self.get_monitors()
        for m in monitors:
            mx, my = m["x"], m["y"]
            scale = m.get("scale", 1.0)
            mw = int(m["width"] / scale)
            mh = int(m["height"] / scale)
            if mx <= cx < mx + mw and my <= cy < my + mh:
                return cx - mx, cy - my, mw, mh, m["name"]

        return cx, cy, 1920, 1080, "unknown"

    def has_active_overlay_panel(self):
        res = self.cmd("j/layers")
        if not res:
            return False
        return "omarchy-keyboard-panel" in res

def main():
    kill_previous_instances()

    def sig_handler(signum, frame):
        sys.exit(0)
    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    client = HyprClient()

    # Start with bar hidden
    hide_bar()

    hide_pending = False
    hide_start_time = 0.0

    last_cursor_pos = (-1, -1)
    last_menu_move_time = 0.0
    last_layer_check_time = 0.0
    panel_active = False

    while True:
        time.sleep(POLL_INTERVAL)

        lx, ly, mw, mh, _ = client.get_cursor_and_monitor()
        if lx is None or ly is None:
            continue

        now = time.time()

        cursor_moved = (lx, ly) != last_cursor_pos
        last_cursor_pos = (lx, ly)

        if now - last_layer_check_time > 0.5:
            last_layer_check_time = now
            panel_active = client.has_active_overlay_panel()

        if bar_is_hidden():
            # Trigger show when cursor touches top edge
            if ly <= SHOW_ZONE:
                show_bar()
                hide_pending = False
                last_menu_move_time = now
            continue

        # --- Bar is currently SHOWN ---

        # 1. Cursor is on the top bar itself
        if ly <= BAR_ZONE:
            hide_pending = False
            last_menu_move_time = now
            continue

        # 2. Check if cursor is in an active popup / menu zone:
        # a) Tray & Retractable drawer menu zone (e.g. Discord, Steam context menus):
        #    Tray is anchored on the right side of the bar (lx >= mw - 800)
        #    Context menus and dropdowns extend down to ~520px
        in_tray_menu_zone = (lx >= (mw - 800)) and (ly <= 520)

        # b) Omarchy application menu zone (top-left):
        in_app_menu_zone = (lx <= 480) and (ly <= 550)

        # c) Center widgets (Clock/calendar, Weather, Spotify):
        in_center_menu_zone = (abs(lx - (mw / 2.0)) <= 400) and (ly <= 550)

        in_menu_zone = in_tray_menu_zone or in_app_menu_zone or in_center_menu_zone or panel_active

        if in_menu_zone:
            if cursor_moved:
                last_menu_move_time = now
            # As long as the user is actively in the menu zone within the timeout, keep bar open
            if (now - last_menu_move_time) < MENU_TIMEOUT or panel_active:
                hide_pending = False
                continue

        # 3. Cursor is outside all interactive/menu zones (e.g. moved down into a window or timed out)
        if not hide_pending:
            hide_pending = True
            hide_start_time = now
        else:
            if (now - hide_start_time) >= HIDE_DELAY:
                hide_bar()
                hide_pending = False

if __name__ == "__main__":
    main()
