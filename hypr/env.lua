-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- screenshot dir
hl.env("HYPRSHOT_DIR", "Pictures/Screenshots")

-- dark mode
hl.env("QT_QPA_PLATFORMTHEME","qt6ct") 
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("QS_ICON_THEME", "AdwaitaLegacy")

-- firefox fix
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("HYPR_SCRIPTS_DIR", "/home/aarushth/.config/hypr/scripts")