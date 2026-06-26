require('autostart')
require('monitors')
require('programs')


require('keybinds')
require('env')
require('animations')
require('look')
require('windows')
----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 0,    
        disable_hyprland_logo   = true, 
		disable_splash_rendering = true, 
		focus_on_activate = true,
    },
})


hl.config({
    plugin = {
        hyprexpo = {
            columns = 3	,
			max_workspace = 12,
			-- rows = 4,
            gaps_in = 5,
            gaps_out = 0,
            bg_col = "rgb(111111)",
            workspace_method = "first 1",
            -- gesture_distance = 30,
            cancel_key = "escape",
            show_cursor = 1,
			keynav_wrap_h = 0,
			keynav_wrap_v = 0
        },
    },
})
