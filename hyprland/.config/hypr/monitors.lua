-- BEGIN hyprmoncfg wake settings
-- Shared with Omarchy while hyprmoncfg manages displays.
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 2 })
-- END hyprmoncfg wake settings
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

hl.monitor({
	output = "eDP-1",
	mode = "2560x1600@120.00",
	position = "0x0",
	scale = omarchy_monitor_scale,
})

hl.monitor({
	output = "HDMI-A-1",
	mode = "3440x1440@100.00",
	position = "2560x0",
	scale = omarchy_monitor_scale,
})

-- Fallback for any other plugged-in monitors
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})
