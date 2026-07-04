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
            columns = 4,
            gaps_in = 3,
            gaps_out = 0,
			workspace_method = "first",
			skip_empty = true,
            cancel_key = "escape",
            show_cursor = 1,
			label_enable = false
        },
    },
})
hl.plugin.hyprexpo.gesture({
    fingers = 4,
    direction = "up",
    action = "expo",
})