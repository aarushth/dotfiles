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
-- suppressMaximizeRule:set_enabled(false)

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
hl.window_rule({
	match = {
		title = "quickshell-wallpaper-picker",
	},
    workspace = "name:wallpaper",
	no_anim = true,
	rounding = 0,
	border_size = 0,
})
hl.workspace_rule({workspace = "name:wallpaper", gaps_out = 0})

--btop
hl.window_rule({
	match = {
		class = "btop",
	},
    workspace = "name:btop",
	-- opacity = 0.5
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
hl.layer_rule({
    match = {
        namespace = "quickshell-notification-card-blur"
    },
    blur = true,
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