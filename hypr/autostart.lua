-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function () 
-- fingerprint login polkit agent
  hl.exec_cmd("pkill -x hyprpolkitagent 2>/dev/null; hyprpolkitagent &")

  hl.exec_cmd("qs")
  
-- top bar
  hl.exec_cmd("waybar &")
  
--   wallpaper
  hl.exec_cmd("awww-daemon &")
  hl.exec_cmd("awww img ~/Pictures/Wallpaper/wp3.png --transition-type wipe &")


-- clipoard history
  hl.exec_cmd("clipse -listen")
  
--   zoxide
  hl.exec_cmd("zoxide init --cmd cd bash")

--   alt tab
--   hl.exec_cmd("q ")


--   oneDrive
  hl.exec_cmd("uwsm app -- /home/aarushth/Applications/OneDriveGUI/AppRun")

-- Dark mode
  hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark &") 


end)
