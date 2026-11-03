--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
hl.layer_rule({
	match = {
		namespace = "rofi",
	},
	order = 1,
})
hl.window_rule({
	match = {
		namespace = ".*", -- wildcard matches all layers
	},
	no_blur = true,
})
hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

-- --btop
hl.window_rule({
	match = {
		class = Browser,
	},
	workspace = "1",
})
hl.window_rule({
	match = {
		class = "btop",
	},
	workspace = "name:btop",
})

for _, app in ipairs({ "spotatui" }) do
	hl.window_rule({
		match = {
			class = app,
		},
		workspace = "empty",
	})
end
for _, game in ipairs({ "theseus", "gamescope", "^(.*minecraft.*)$", "^(.*Minecraft.*)$" }) do
	hl.window_rule({
		match = {
			class = game,
		},
		tag = "+games",
	})
end
hl.window_rule({
	match = { tag = "games" },
	fullscreen = true,
	workspace = "empty",
})
for _, className in ipairs({
	"float",
	"OneDriveGUI",
	"com.gabm.satty",
	"warp-taskbar",
	"hyprland-share-picker",
	"bitwarden",
	"zoom",
}) do
	hl.window_rule({
		match = { class = className },
		tag = "+float",
	})
end
for _, className in ipairs({
	"float",
}) do
	hl.window_rule({
		match = { class = className },
		size = "625 650",
	})
end
hl.on("window.open", function(w)
	if w.class ~= Browser then
		return
	end
	if w.initial_title ~= "Mozilla Firefox" then
		return
	end

	local ff_windows = hl.get_windows({ class = Browser })
	if #ff_windows <= 1 then
		return
	end

	hl.dispatch(hl.dsp.window.float({ action = "set", window = w }))

	local sub
	sub = hl.on("window.title", function(tw)
		if tw.address ~= w.address then
			return
		end
		if
			tw.title == ""
			or tw.title == "Mozilla Firefox"
			or tw.title == "about:blank"
			or tw.title:match("^about:.*Mozilla Firefox$")
		then
			return
		end

		sub:remove()

		if tw.title:match("^Extension:") then
			hl.dispatch(hl.dsp.window.resize({ x = 800, y = 600, window = tw }))
			hl.dispatch(hl.dsp.window.center({ window = tw }))
			hl.dispatch(hl.dsp.focus({ window = tw }))
		else
			hl.dispatch(hl.dsp.window.float({ action = "unset", window = tw }))
		end
	end)
end)
hl.window_rule({
	match = { tag = "float" },
	float = true,
	center = true,
})
