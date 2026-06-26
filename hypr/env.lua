-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- dark mode
hl.env("QT_QPA_PLATFORMTHEME","qt6ct") 
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("QS_ICON_THEME", "AdwaitaLegacy")

-- firefox extensions fix
hl.env("MOZ_ENABLE_WAYLAND", "1")