-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- windowrule = match:fullscreen true, confine_pointer 1

hl.window_rule({
	match = {
		class = "steam_app_.*",
		fullscreen = true,
	},
	confine_pointer = true,
})

hl.config({
	general = {
		-- No gaps between windows or borders.
		gaps_in = 3,
		gaps_out = 2,
		border_size = 0,
		-- Change to niri-like side-scrolling layout.
		-- layout = "scrolling",
		resize_on_border = true,
		extend_border_grab_area = 15,
		hover_icon_on_border = true,
		allow_tearing = true,
	},
	misc = {
		vrr = 2, -- VRR ALWAYS ON WHEN FULLSCREEN (prevents mode-switch flickering when entering fullscreen)
	},
	render = {
		direct_scanout = 1, -- Enables direct scanout for lowest input latency in fullscreen games
	},
	cursor = {
		no_hardware_cursors = true, -- Prevents cursor-related flickering with VRR
	},
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
	decoration = {
		-- Use round window corners.
		rounding = 8,

		-- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
		dim_inactive = true,
		dim_strength = 0.15,
	},
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
hl.config({
	animations = {
		enabled = true,
	},
})

-- Add snappy, fast, and smooth animations
hl.curve("snappy", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("smoothOut", { type = "bezier", points = { { 0.36, 0 }, { 0.66, -0.56 } } })
hl.curve("smoothIn", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })
hl.curve("fastSlide", { type = "bezier", points = { { 0.1, 1 }, { 0.2, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "snappy", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "smoothOut", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "snappy" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "fastSlide", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "fastSlide", style = "slidevert" })
hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "snappy", style = "fade" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "smoothIn" })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- >>> omaland managed block >>>
-- Written by Omaland. Safe to hand-edit: Omaland re-reads this block
-- every time it opens, and only ever rewrites what's between the fences.
hl.config({
  animations = {
    workspace_wraparound = false,
  },

  decoration = {
    dim_inactive = false,
    rounding = 14,

    glow = {
      enabled = false,
      range = 19,
    },

    shadow = {
      enabled = true,
    },
  },

  general = {
    border_size = 0,
    gaps_in = 3,
    gaps_out = 5,
    gaps_workspaces = 0,

    snap = {
      enabled = false,
    },
  },
})
-- <<< omaland managed block <<<
