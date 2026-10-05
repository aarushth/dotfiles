-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("awww-daemon --no-cache")
	hl.exec_cmd("qs")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

	hl.exec_cmd("onedrive-gui")
	-- hl.exec_cmd("flatpak run com.bitwarden.desktop")
	--desktop portal for screenshare
	hl.exec_cmd("systemctl --user start hyprland-session.target")

	-- clipoard history
	hl.exec_cmd("clipse -listen")

	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprpm update")
	hl.exec_cmd("hyprpm reload")
end)

hl.on("hyprland.shutdown", function()
	os.execute("systemctl --user stop hyprland-session.target && sleep 0.1")
end)
