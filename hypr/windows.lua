--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
hl.layer_rule({
	match = {
		namespace = "rofi"
	},
	order = 1
})
hl.layer_rule({
    match = {
        namespace = ".*"  -- wildcard matches all layers
    },
	blur = false,
})
hl.window_rule({
	match = {
        namespace = ".*"  -- wildcard matches all layers
    },
	no_blur = true
})
hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

--clipse floating
hl.window_rule({
    match = {
        class = "clipse",
		
    },
    float = true,
    size = "622 652",
	border_size = 2,
    
})

--btop
hl.window_rule({
	match = {
		class = "btop",
	},
    workspace = "name:btop",
})

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



-- satty floating
hl.window_rule({
    match = {
        title = "satty",
		
    },
    float = true,
    size = "600 400"
    
})

-- yazi floating as filepicker
hl.window_rule({
    match = {
    	title = "termfilechooser",
    },
    float = true,
    size = "622 652",
	border_size = 2,
})



-- notification blur

