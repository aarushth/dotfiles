-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function () 
--   oneDrive
  hl.exec_cmd("uwsm app -- /home/aarushth/Applications/OneDriveGUI/AppRun")

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

-- Dark mode
  hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark &") 

end)
