
---------------------
---- KEYBINDINGS ----
---------------------
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = 0.5, 
        touchpad = {
            natural_scroll = true,
			clickfinger_behavior = false,
			middle_button_emulation = true,
			tap_to_click = false
        },
    },
})
hl.device({
    name = "tpps/2-elan-trackpoint",
    sensitivity = -0.5
})
hl.device({
    name = "sinowealth-game-mouse",
    sensitivity = -1
})
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})


mainMod = "SUPER"
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + J", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("kitty -o background_opacity=1.0 --class clipse -e clipse "))
hl.bind("CTRL + ALT + Backspace", function ()
	for _, window in pairs(hl.get_windows()) do
		if window.class == "btop" then
			return hl.dispatch(hl.dsp.focus({workspace = "name:btop", on_current_monitor = true}))
		end
	end
	hl.dispatch(hl.dsp.exec_cmd("kitty --class btop -e btop"))
end)
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("rofimoji --action clipboard"))
hl.bind("XF86Assistant", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.layout("togglesplit"))

--screenshot
screenshotCmd = "grim -g \"$(slurp)\" -t ppm - | satty -f - --copy-command wl-copy --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png"
hl.bind("XF86SelectiveScreenshot", hl.dsp.exec_cmd(screenshotCmd))
hl.bind("XF86Launch5", hl.dsp.exec_cmd(screenshotCmd))
hl.bind("Print", hl.dsp.exec_cmd("grim -o " .. hl.get_active_monitor().name .." - | satty -f - --copy-command wl-copy --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png"))

--hyprexpo overview
hl.bind("ALT + TAB", function()
    hl.plugin.hyprexpo.expo("toggle")
end)
hl.define_submap("hyprexpo", function()
    hl.bind("left",      function() hl.plugin.hyprexpo.kb_focus("left") end)
    hl.bind("right",      function() hl.plugin.hyprexpo.kb_focus("right") end)
    hl.bind("up",      function() hl.plugin.hyprexpo.kb_focus("up") end)
    hl.bind("down",      function() hl.plugin.hyprexpo.kb_focus("down") end)
	hl.bind("TAB", function() hl.plugin.hyprexpo.kb_focus("next") end)
	hl.bind("SHIFT + TAB", function() hl.plugin.hyprexpo.kb_focus("previous") end)
    hl.bind("return", function() hl.plugin.hyprexpo.kb_confirm() end)
    hl.bind("escape", function() hl.plugin.hyprexpo.expo("cancel") end)
	hl.bind("ALT + TAB", function() hl.plugin.hyprexpo.kb_confirm() end)
end)

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))


-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i, on_current_monitor = true}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

--browser
function openFirefox()
	hl.dispatch(hl.dsp.focus({ workspace = 1, on_current_monitor = true}))
	for _, window in pairs(hl.get_windows()) do
		if window.class == "firefox" then
			return hl.dispatch(hl.dsp.no_op())
		end
	end
	hl.dispatch(hl.dsp.exec_cmd("firefox"))
end
hl.bind(mainMod .. " + 1", openFirefox)
hl.bind("XF86HomePage", openFirefox)

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 & wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+ & qs ipc call osd volume"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 & wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%- & qs ipc call osd volume"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle & qs ipc call osd volume"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle & qs ipc call osd volume "),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -q set 5%+ & qs ipc call osd brightness"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -q set 5%- & qs ipc call osd brightness"),                  { locked = true, repeating = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"))

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left"}))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right"}))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up"}))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down"}))

-- 
resizeFactor = 20
hl.bind(mainMod .. " + ALT + left", hl.dsp.window.resize({ x = -10, y = 0, relative = true}), {repeating = true})
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.resize({ x = 10, y = 0, relative = true}), {repeating = true})
hl.bind(mainMod .. " + ALT + up", hl.dsp.window.resize({ x = 0, y = -10, relative = true}), {repeating = true})
hl.bind(mainMod .. " + ALT + down", hl.dsp.window.resize({ x = 0, y = 10, relative = true}), {repeating = true})

