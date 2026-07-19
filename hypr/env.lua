-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("HYPRCURSOR_SIZE", "24")
-- hl.env("PATH", "$PATH:/home/aarushth/.cargo/bin")
-- dark mode
hl.env("QT_QPA_PLATFORMTHEME","qt6ct") 
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("QS_ICON_THEME", "AdwaitaLegacy")
hl.env("PATH", os.getenv("PATH")..":"..os.getenv("HOME").."/.cargo/bin")

-- firefox extensions fix
hl.env("MOZ_ENABLE_WAYLAND", "1")

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
