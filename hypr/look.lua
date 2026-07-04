-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 2,
        gaps_out = 1,

        border_size = 2,

        col = {
            active_border   = { colors = {"rgba(4B09F5ee)", "rgba(02C939ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
		
    },
	dwindle = {
		preserve_split = true,
	},
    xwayland = {
        force_zero_scaling = true
    },
    decoration = {
        rounding       = 10,
        rounding_power = 2,

        shadow = {
            enabled = false,
        },
		blur = {
			enabled = true,
		}
    },

    animations = {
        enabled = true,
    },
})
