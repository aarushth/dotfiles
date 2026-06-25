
---------------------
---- KEYBINDINGS ----
---------------------


local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + J", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("kitty --class clipse -e clipse"))
hl.bind(mainMod .. " + W", function()
    hl.dispatch(hl.dsp.focus({workspace = "name:wallpaper"}))
	hl.dispatch(hl.dsp.exec_cmd("qs ipc call wallpaper open"))
end)
hl.bind("CTRL + ALT + Backspace", function()
    hl.dispatch(hl.dsp.focus({workspace = "name:btop"}))
	hl.dispatch(hl.dsp.exec_cmd("kitty -e btop"))
end)
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("rofimoji --action clipboard"))
hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.layout("togglesplit"))    -- dwindle only
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))

hl.bind("ALT + f4", function ()
	if hl.get_active_window().title == "quickshell-wallpaper-picker" then
		hl.dispatch(hl.dsp.exec_cmd("qs ipc call wallpaper close"))
	else
		hl.dispatch(hl.dsp.window.close())
	end
end)


hl.bind("ALT + TAB", hl.dsp.exec_cmd("qs ipc call overview open_forward"), { consuming = false })
hl.bind("ALT + SHIFT + TAB", hl.dsp.exec_cmd("qs ipc call overview open_backward"), {non_consuming = true})
hl.bind("ALT + ALT_L", hl.dsp.exec_cmd("qs ipc call overview close"), {release = true})
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("wlogout"))
-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("qs ipc call notifications dismiss_hovered"))
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("qs ipc call notifications dismiss_all"))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + 1", 
	function ()
		local is_firefox_running = false

		for _, window in pairs(hl.get_windows()) do
			if window.class == "org.mozilla.firefox" then
				is_firefox_running = true
				break
			end
		end

		if not is_firefox_running then
    		hl.dispatch(hl.dsp.exec_cmd("firefox"))
		end
	end)


-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 & wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+ & qs ipc call osd volume"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 & wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%- & qs ipc call osd volume"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle & qs ipc call osd volume"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -q set 5%+ & qs ipc call osd brightness"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -q set 5%- & qs ipc call osd brightness"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- lock on lid close
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprlock"), { locked = true })

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left"}))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right"}))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up"}))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down"}))
