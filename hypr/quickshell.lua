-- remove decorations for wallpaperPicker so it takes up the whole screen
hl.window_rule({
	match = {
		title = "quickshell-wallpaper-picker",
	},
	workspace = "name:wp1",
	no_anim = true,
	rounding = 0,
	border_size = 0,
})
hl.workspace_rule({ workspace = "name:wp1", gaps_out = 0 })

-- add blur to actual notification card, but not to reveal animation
hl.layer_rule({
	match = {
		namespace = "quickshell-notification-card-blur",
	},
	blur = true,
	order = 2,
	no_anim = true,
})
hl.config({
	decoration = {
		blur = {
			size = 7,
			passes = 2,
		},
	},
})
for _, name in ipairs({ "quickshell-notification-card", "quickshell-osd", "quickshell-wlogout", "quickshell-start" }) do
	hl.layer_rule({
		match = {
			namespace = name,
		},
		order = 1,
	})
end
hl.layer_rule({
	match = {
		namespace = "quickshell-lockscreen",
	},
	order = 0,
})
-- no fade-in, otherwise the desktop shows through when the session lock drops
hl.layer_rule({
	match = {
		namespace = "quickshell-unlockscreen",
	},
	order = 0,
	no_anim = true,
})

-- toggle wallpaper picker
hl.bind(MainMod .. " + SHIFT + W", hl.dsp.focus({ workspace = "name:wp", on_current_monitor = true }))
function SwitchToWallpaperWs()
	for _, monitor in ipairs(hl.get_monitors()) do
		hl.dispatch(hl.dsp.focus({ monitor = monitor.name }))
		hl.dispatch(hl.dsp.focus({ workspace = "name:wp" .. _, on_current_monitor = true }))
	end
end
hl.bind(MainMod .. " + R", hl.dsp.exec_cmd("qs ipc call main reload"))

hl.bind(MainMod .. " + I", hl.dsp.exec_cmd("qs ipc call idle toggle"))
--notifications
hl.bind(MainMod .. " + X", hl.dsp.exec_cmd("qs ipc call notifications dismiss_all"))
