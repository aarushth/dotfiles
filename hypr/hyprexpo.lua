hl.config({
	plugin = {
		hyprexpo = {
			gaps_in = 3,
			gaps_out = 3,
			bg_col = "rgb(111111)",
			gesture_distance = 200,
			show_cursor = 1,
			border_width = 3,
			border_color_current = "rgba(11111100)",
			border_color_hover = "rgba(11111100)",
			border_color_focus = "rgba(4B09F5ee) rgba(02C939ee) 45deg",
		},
	},
})

hl.bind("ALT + TAB", function()
	hl.plugin.hyprexpo.expo("toggle")
end, { non_consuming = true })

hl.bind("ALT + SHIFT + TAB", function()
	hl.plugin.hyprexpo.expo("toggle")
end, { non_consuming = true })

hl.define_submap("hyprexpo", function()
	hl.bind("ALT + h", function()
		hl.plugin.hyprexpo.kb_focus("left")
	end)
	hl.bind("ALT + l", function()
		hl.plugin.hyprexpo.kb_focus("right")
	end)
	hl.bind("ALT + k", function()
		hl.plugin.hyprexpo.kb_focus("up")
	end)
	hl.bind("ALT + j", function()
		hl.plugin.hyprexpo.kb_focus("down")
	end)
	hl.bind("ALT + left", function()
		hl.plugin.hyprexpo.kb_focus("left")
	end)
	hl.bind("ALT + right", function()
		hl.plugin.hyprexpo.kb_focus("right")
	end)
	hl.bind("ALT + up", function()
		hl.plugin.hyprexpo.kb_focus("up")
	end)
	hl.bind("ALT + down", function()
		hl.plugin.hyprexpo.kb_focus("down")
	end)
	hl.bind("ALT + TAB", function()
		hl.plugin.hyprexpo.kb_focus("next")
	end, { non_consuming = true })
	hl.bind("ALT + SHIFT + TAB", function()
		hl.plugin.hyprexpo.kb_focus("previous")
	end, { non_consuming = true })
	hl.bind("return", function()
		hl.plugin.hyprexpo.kb_confirm()
	end)
	hl.bind("escape", function()
		hl.plugin.hyprexpo.expo("cancel")
	end)
	hl.bind("ALT_L", function()
		hl.plugin.hyprexpo.kb_confirm()
	end, { release = true, submap_universal = true, ignore_mods = true, transparent = true })
end)
