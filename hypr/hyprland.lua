require("autostart")
require("programs")
require("keybinds")
require("env")
require("animations")
require("look")
require("windows")
require("quickshell")
require("hyprexpo")

do
	local path = os.getenv("HOME") .. "/.config/hypr/hyprmoncfg-monitors.lua"
	local file = io.open(path, "r")
	if file then
		file:close()
		dofile(path)
	end
end
hl.bind("SUPER + Escape", function()
	hl.dispatch(hl.dsp.submap("clean"))
	hl.dispatch(hl.dsp.exec_cmd("qs ipc call bar submapEntered"))
end)
hl.define_submap("clean", function()
	hl.bind("SUPER + Escape", function()
		hl.dispatch(hl.dsp.submap("reset"))
		hl.dispatch(hl.dsp.exec_cmd("qs ipc call bar submapExited"))
	end)
end)

-- Added by hyprmoncfg: its generated monitor rules load last, so nothing before this can override the applied layout.
do local path = os.getenv("HOME") .. "/.config/hypr/hyprmoncfg-monitors.lua"; local file = io.open(path, "r"); if file then file:close(); dofile(path) end end
