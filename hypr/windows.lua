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
hl.layer_rule({
	match = {
		namespace = ".*", -- wildcard matches all layers
	},
	blur = false,
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
		class = "firefox",
	},
	workspace = "1",
})
hl.window_rule({
	match = {
		class = "btop",
	},
	workspace = "name:btop",
})
hl.window_rule({
	match = {
		class = "spotify",
	},
	workspace = "empty",
})
for _, game in ipairs({ "theseus", "steam", "^(steam_app_.*)$" }) do
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

-- emails
hl.window_rule({
	match = {
		title = "Outlook uw",
	},
	workspace = "name:uw",
})
hl.window_rule({
	match = {
		title = "Outlook personal",
	},
	workspace = "name:mail",
})
hl.window_rule({
	match = {
		title = "Outlook cse",
	},
	workspace = "name:cse",
})
hl.window_rule({
	match = {
		title = "gmail",
	},
	workspace = "name:gmail",
})
hl.window_rule({
	match = {
		title = "Zoho Mail",
	},
	workspace = "name:zoho",
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
	"OneDriveGUI",
}) do
	hl.window_rule({
		match = { class = className },
		size = "625 650",
	})
end
local handled = {}
hl.on("window.title", function(w)
	if handled[w.address] then
		return
	end
	for _, pat in ipairs({ "Extension" }) do
		if w.title:find(pat, 1, true) then
			handled[w.address] = true
			hl.dispatch(hl.dsp.window.float({ action = "enable", window = w }))
			hl.dispatch(hl.dsp.window.center({ window = w }))
			return
		end
	end
end)

hl.window_rule({
	match = { tag = "float" },
	float = true,
	center = true,
})
