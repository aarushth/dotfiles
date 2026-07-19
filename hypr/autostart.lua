-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function () 

	hl.exec_cmd("qs")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

	hl.exec_cmd("onedrive-gui")
	--desktop portal for screenshare
	hl.exec_cmd("systemctl --user start hyprland-session.target")

	-- --   wallpaper daemon
	hl.exec_cmd("awww-daemon &")

	-- clipoard history
	hl.exec_cmd("clipse -listen")

	-- plugins
	hl.exec_cmd("hyprpm reload")
	hl.exec_cmd("hypridle")
end)

hl.on("hyprland.shutdown", function()
    os.execute("systemctl --user stop hyprland-session.target && sleep 0.1")
    -- uses a blocking exec function and sleeps a bit to give things time to close
    -- you might also want to kill troublesome/crashing non-systemd background services here:
    -- os.execute("pkill wallpaperthing; systemctl --user stop hyprland-session.target && sleep 0.1")
end)