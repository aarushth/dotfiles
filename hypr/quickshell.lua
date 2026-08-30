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
-- make sure reveal animation for notification card is ontop of actual card
hl.layer_rule({
	match = {
		namespace = "quickshell-notification-card",
	},
	order = 1,
})

-- all these other overlay layers need to be below lockscreen
hl.layer_rule({
	match = {
		namespace = "quickshell-osd",
	},
	order = 1,
})
hl.layer_rule({
	match = {
		namespace = "quickshell-wlogout",
	},
	order = 1,
})
hl.layer_rule({
	match = {
		namespace = "quickshell-lockscreen",
	},
	order = 0,
})

-- loginctl lock-session is set to 'qs ipc call lockscreen lock' in my hypridle.conf
hl.bind(MainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))

-- toggle wallpaper picker
hl.bind(MainMod .. " + W", hl.dsp.exec_cmd("qs ipc call wallpaper toggle"))
hl.bind(MainMod .. " + SHIFT + W", hl.dsp.focus({ workspace = "name:wp", on_current_monitor = true }))
function SwitchToWallpaperWs()
	for _, monitor in ipairs(hl.get_monitors()) do
		hl.dispatch(hl.dsp.focus({ monitor = monitor.name }))
		hl.dispatch(hl.dsp.focus({ workspace = "name:wp" .. _, on_current_monitor = true }))
	end
end
-- override window.close for wallpaper-picker so close animation plays cleanly
hl.bind("ALT + f4", function()
	if not (hl.get_active_window() == "null") and hl.get_active_window().title == "quickshell-wallpaper-picker" then
		hl.dispatch(hl.dsp.exec_cmd("qs ipc call wallpaper close"))
	else
		hl.plugin.feedloss.close()
	end
end)
hl.bind(MainMod .. " + R", hl.dsp.exec_cmd("qs ipc call main reload"))
-- toggle wlogout
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("qs ipc call wlogout toggle"))

--notifications
hl.bind(MainMod .. " + X", hl.dsp.exec_cmd("qs ipc call notifications dismiss_hovered"))
hl.bind(MainMod .. " + SHIFT + X", hl.dsp.exec_cmd("qs ipc call notifications dismiss_all"))
