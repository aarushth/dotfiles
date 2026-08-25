require('autostart')
require('monitors')
require('programs')


require('keybinds')
require('env')
require('animations')
require('look')
require('windows')
require('quickshell')
----------------
----  MISC  ----
----------------
 
hl.config({
    misc = {
        force_default_wallpaper = 0,    
        disable_hyprland_logo   = true, 
		disable_splash_rendering = true, 
		focus_on_activate = true,
		enable_anr_dialog = false
    },
})
hl.config({
    plugin = {
        hyprexpo = {
            gaps_in = 0,
            gaps_out = 0,
            bg_col = "rgb(111111)",
            gesture_distance = 200,
            show_cursor = 1,
			border_width = 3,
			border_color_focus = "rgb(02C939)"
        },
    },
})