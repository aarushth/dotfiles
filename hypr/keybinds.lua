---------------------
---- KEYBINDINGS ----
---------------------
hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		follow_mouse = 1,
		sensitivity = 0.5,
		touchpad = {
			natural_scroll = true,
			clickfinger_behavior = false,
			middle_button_emulation = true,
			tap_to_click = false,
		},
	},
})
hl.device({
	name = "tpps/2-elan-trackpoint",
	sensitivity = -0.75,
	scroll_factor = 0.2,
})
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

MainMod = "SUPER"

function OpenInCustomWorkspace(program, command, ws)
	for _, window in pairs(hl.get_windows()) do
		if window.class == program then
			return hl.dispatch(hl.dsp.focus({ workspace = ws, on_current_monitor = true }))
		end
	end
	hl.dispatch(hl.dsp.exec_cmd(command))
end
local function floatingTuiCmd(command)
	return Terminal .. " -o background_opacity=1.0 --class float -e " .. command
end

hl.bind(MainMod .. " + Q", hl.dsp.exec_cmd(Terminal))
hl.bind(MainMod .. " + F", hl.dsp.window.fullscreen_state({ action = "toggle", internal = 2, client = -1 }))
hl.bind(MainMod .. " + J", hl.dsp.window.float({ action = "toggle" }))
hl.bind(MainMod .. " + P", hl.dsp.layout("togglesplit"))
hl.bind(MainMod .. " + L", hl.dsp.exec_cmd(Lock))
hl.bind("ALT + f4", hl.dsp.window.close())

hl.bind(MainMod .. " + W", function()
	hl.exec_cmd(WallpaperSwitcher)
	hl.dispatch(hl.dsp.focus({ workspace = "name:wp1", on_current_monitor = true }))
end)
hl.bind(MainMod .. " + E", hl.dsp.exec_cmd(Terminal .. " --hold bash -ci " .. FileManager))
hl.bind(MainMod .. " + V", hl.dsp.exec_cmd(floatingTuiCmd(ClipboardManager)))
hl.bind(MainMod .. " + M", hl.dsp.exec_cmd(floatingTuiCmd(MonitorManager)))
hl.bind("CTRL + ALT + Backspace", function()
	OpenInCustomWorkspace(
		TaskManager,
		Terminal .. " --class " .. TaskManager .. " -e " .. TaskManager,
		"name:" .. TaskManager
	)
end)
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd(WLogout))

hl.bind(MainMod .. " + period", hl.dsp.exec_cmd(EmojiPicker))
hl.bind(MainMod .. " + SUPER_L", hl.dsp.exec_cmd(Menu))
hl.bind("XF86SelectiveScreenshot", hl.dsp.exec_cmd(SelectiveScreenshot))
hl.bind("XF86Launch5", hl.dsp.exec_cmd(SelectiveScreenshot))
hl.bind("Print", hl.dsp.exec_cmd(Screenshot))

hl.bind("SUPER + SHIFT + F23", hl.dsp.exec_cmd("pkill wl-kbptr || wl-kbptr click"))
hl.bind("CTRL + SPACE", hl.dsp.exec_cmd("wlrctl pointer click left"))
hl.bind("ALT + SPACE", hl.dsp.exec_cmd("wlrctl pointer click right"))

-- Move focus with MainMod + arrow keys
hl.bind(MainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(MainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(MainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(MainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with MainMod + [0-9]
-- Move active window to a workspace with MainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(MainMod .. " + " .. key, hl.dsp.focus({ workspace = i, on_current_monitor = true }))
	hl.bind(MainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(MainMod .. " + 1", function()
	OpenInCustomWorkspace(Browser, Browser, "1")
end)
hl.bind("XF86HomePage", function()
	OpenInCustomWorkspace(Browser, Browser, "1")
end)

hl.bind(MainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(
		"wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 & wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+ & qs ipc call osd volume"
	),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(
		"wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 & wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%- & qs ipc call osd volume"
	),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle & qs ipc call osd volume"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle & qs ipc call osd mic"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl -q set 5%+ & qs ipc call osd brightness"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl -q set 5%- & qs ipc call osd brightness"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))

hl.bind(MainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(MainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(MainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(MainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

--
local resizeFactor = 20
hl.bind(
	MainMod .. " + ALT + left",
	hl.dsp.window.resize({ x = -resizeFactor, y = 0, relative = true }),
	{ repeating = true }
)
hl.bind(
	MainMod .. " + ALT + right",
	hl.dsp.window.resize({ x = resizeFactor, y = 0, relative = true }),
	{ repeating = true }
)
hl.bind(
	MainMod .. " + ALT + up",
	hl.dsp.window.resize({ x = 0, y = -resizeFactor, relative = true }),
	{ repeating = true }
)
hl.bind(
	MainMod .. " + ALT + down",
	hl.dsp.window.resize({ x = 0, y = resizeFactor, relative = true }),
	{ repeating = true }
)
