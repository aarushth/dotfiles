-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 1,

		border_size = 2,

		col = {
			active_border = { colors = { "rgba(4B09F5ee)", "rgba(02C939ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},

		-- Set to true to enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = true,

		-- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
		allow_tearing = false,

		layout = "dwindle",
	},
	dwindle = {
		preserve_split = true,
	},
	xwayland = {
		force_zero_scaling = true,
	},
	decoration = {
		rounding = 0,
		shadow = {
			enabled = false,
		},
		blur = {
			enabled = true,
		},
	},

	animations = {
		enabled = true,
	},
})
hl.on("monitor.layout_changed", function()
	hl.exec_cmd("sleep 2 && awww restore")
end)

hl.config({
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		focus_on_activate = true,
		enable_anr_dialog = false,
	},
})
-- hl.config({
-- 	plugin = {
-- 		["3la_feed_loss"] = {
-- 			duration = 100,
-- 			fade = 100,
-- 			close_at = 1.0,
--
-- 			static_alpha = 0.0,
-- 			glitch = 5,
--
-- 			text = "",
--
-- 			["col.fringe1"] = "#4B09F5ee",
-- 			["col.fringe2"] = "#02C939ee",
--
-- 			min_size = 80,
-- 			ignore_children = 1,
--
-- 			-- Regex (C++ std::regex, NOT a Lua pattern) of window classes to never
-- 			ignore_class = "^(xdg-desktop-portal.*)$",
--
-- 			ignore_title = "",
-- 		},
-- 	},
-- })
