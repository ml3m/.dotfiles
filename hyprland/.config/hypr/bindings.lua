-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Toggle Omarchy Bar Autohide
o.bind("SUPER + ALT + H", "Toggle Bar Autohide", "bash ~/.config/omarchy/toggle-autohide.sh")
-- BEGIN Waypaper Video background selector
-- Replaces the stock Omarchy Background switcher binding with the direct selector.
hl.unbind("SUPER + CTRL + SPACE")
o.bind(
	"SUPER + CTRL + SPACE",
	"Waypaper Video backgrounds",
	"$HOME/.config/omarchy/plugins/io.github.gavidetdoliath.waypaper-video-background/background-selector.sh"
)
-- END Waypaper Video background selector

-- Toggle Autoclicker
-- o.bind("SUPER + SHIFT + J", "Toggle Autoclicker", "/home/ml3m/autoclick.sh")
