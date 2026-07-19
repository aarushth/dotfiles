-- remove decorations for wallpaperPicker so it takes up the whole screen
hl.window_rule({
	match = {
		title = "quickshell-wallpaper-picker",
	},
    workspace = "name:wp",
	no_anim = true,
	rounding = 0,
	border_size = 0,
})
hl.workspace_rule({workspace = "name:wp", gaps_out = 0})

-- add blur to actual notification card, but not to reveal animation
hl.layer_rule({
    match = {
        namespace = "quickshell-notification-card-blur"
    },
    blur = true,
	order = 2,
	no_anim = true
})
hl.config({
    decoration = {
        blur = {
            size = 7,
            passes = 2,
        }
    }
})
-- make sure reveal animation for notification card is ontop of actual card
hl.layer_rule({
	match = {
		namespace = "quickshell-notification-card"
	},
	order = 1
})

-- all these other overlay layers need to be below lockscreen
hl.layer_rule({
	match = {
		namespace = "quickshell-osd"
	},
	order = 1
})
hl.layer_rule({
	match = {
		namespace = "quickshell-wlogout"
	},
	order = 1
})
hl.layer_rule({
	match = {
		namespace = "quickshell-lockscreen"
	},
	order = 0
})

-- loginctl lock-session is set to 'qs ipc call lockscreen lock' in my hypridle.conf
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
-- toggle wallpaper picker
hl.bind(mainMod .. " + W", function()
	hl.dispatch(hl.dsp.exec_cmd("qs ipc call wallpaper toggle"))
	hl.dispatch(hl.dsp.focus({workspace = "name:wp"}))
end)

-- override window.close for wallpaper-picker so close animation plays cleanly
hl.bind("ALT + f4", function ()
	if hl.get_active_window().title == "quickshell-wallpaper-picker" then
		hl.dispatch(hl.dsp.exec_cmd("qs ipc call wallpaper close"))
	else
		hl.dispatch(hl.dsp.window.close())
	end
end)

-- toggle wlogout
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("qs ipc call wlogout toggle"))

--notifications
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("qs ipc call notifications dismiss_hovered"))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("qs ipc call notifications dismiss_all"))
