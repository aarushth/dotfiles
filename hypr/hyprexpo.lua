hl.config({
	plugin = {
		hyprexpo = {
			gaps_in = 3,
			gaps_out = 0,
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
end)
hl.define_submap("hyprexpo", function()
	hl.bind("left", function()
		hl.plugin.hyprexpo.kb_focus("left")
	end)
	hl.bind("right", function()
		hl.plugin.hyprexpo.kb_focus("right")
	end)
	hl.bind("up", function()
		hl.plugin.hyprexpo.kb_focus("up")
	end)
	hl.bind("down", function()
		hl.plugin.hyprexpo.kb_focus("down")
	end)
	hl.bind("TAB", function()
		hl.plugin.hyprexpo.kb_focus("next")
	end)
	hl.bind("SHIFT + TAB", function()
		hl.plugin.hyprexpo.kb_focus("previous")
	end)
	hl.bind("return", function()
		hl.plugin.hyprexpo.kb_confirm()
	end)
	hl.bind("escape", function()
		hl.plugin.hyprexpo.expo("cancel")
	end)
	hl.bind("ALT + TAB", function()
		hl.plugin.hyprexpo.kb_confirm()
	end)
end)
