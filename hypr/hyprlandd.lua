hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		follow_mouse = 1,
		sensitivity = 0.5,
		touchpad = {
			natural_scroll = true,
			clickfinger_behavior = false,
			middle_button_emulation = true,
			tap_to_click = false,
		},
	},
})
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
	},
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		focus_on_activate = true,
		enable_anr_dialog = false,
	},

	animations = {
		enabled = true,
	},
})
MainMod = "SUPER"

hl.bind(MainMod .. " + Q", hl.dsp.exec_cmd("kitty -o remember_window_size=no"))
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(MainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(MainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(MainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(MainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(MainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(MainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.monitor({
	output = "WAYLAND-1",
	position = "0x0",
	scale = 1,
	mode = "1920x1080",
})
hl.bind("SUPER + C", hl.dsp.window.close())
