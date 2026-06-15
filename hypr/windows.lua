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
    size = "622 652"
    
})

--emojify floating
hl.window_rule({
    match = {
        class = "xyz.riothedev.emojify",
    },
    float = true,
    size = "400 400"
})


--wallpaper picker
hl.window_rule({
    name = "wallpaper-picker",

    match = {
        class = "WallpaperPicker",
    },

    workspace = "special:wallpicker",
    float = true,
    center = true,
})