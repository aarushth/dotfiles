require("autostart")
require("programs")
require("keybinds")
require("env")
require("animations")
require("look")
require("windows")
require("quickshell")
require("hyprexpo")

-- Added by hyprmoncfg: its generated monitor rules load last, so nothing before this can override the applied layout.
dofile(os.getenv("HOME") .. "/.config/hypr/hyprmoncfg-monitors.lua")
