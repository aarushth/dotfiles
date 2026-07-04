-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function () 

  hl.exec_cmd("uwsm app -- qs")
  
-- top bar
  hl.exec_cmd("uwsm app -- waybar")
  
-- daemons
-- --   wallpaper daemon
  hl.exec_cmd("awww-daemon &")

-- clipoard history
  hl.exec_cmd("clipse -listen")

-- plugins
  hl.exec_cmd("hyprpm reload")
end)
