-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function () 
-- fingerprint login polkit agent
  hl.exec_cmd("systemctl --user enable --now hyprpolkitagent.service")

  hl.exec_cmd("qs")
  
-- top bar
  hl.exec_cmd("waybar &")
  
-- --   wallpaper daemon
  hl.exec_cmd("awww-daemon &")


-- clipoard history
  hl.exec_cmd("clipse -listen")
  
--   zoxide
  hl.exec_cmd("zoxide init --cmd cd bash")

--   oneDrive
  hl.exec_cmd("uwsm app -- /home/aarushth/Applications/OneDriveGUI/AppRun")

-- Dark mode
  hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark &") 


end)
