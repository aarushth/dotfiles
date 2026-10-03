

https://github.com/user-attachments/assets/635b3707-8814-4f9a-ab86-45875b963859

# Dotfiles
My (highly opinionated) configuration inspired by the artstyle of the sci fi game Marathon (the new one, not the original trilogy, though I love the originals too).
Includes:
- Quickshell
  - bottom bar with dock, wifi/bluetooth controls, media player, dock, system tray, idle inhibitor, power mode controls, audio sink/source controls, and date/time
  - notification manager
  - lockscreen
  - volume, brightness and mic OSD
  - logout menu
  - wallpaper picker
  - app launcher (WIP)
- cava for bottom bar media player
- Hyprland config for colors custom keybinds for quickshell, window rules, etc.
- kitty, neovim, and yazi
- xdg-desktop-portal-termfilechooser: to set yazi as my system file chooser
- hyprmoncfg for monitor management
- custom spicetify theme + snippets to clean up.

# Basic setup
You will need these fonts:
- [KH Interference TRIAL](https://khtype.com/typeface/kh-interference/)
- [Specify Personal Extrexpanded](https://font.download/font/specify)
- [PP Fraktion Mono](https://pangrampangram.com/products/fraktion-mono)
- [Symbols Nerd Font](https://www.nerdfonts.com/font-downloads)

Other requirements:
- [qt6 and its associated packages](https://www.qt.io/development/qt-framework/qt6)
- [quickshell](https://quickshell.org/)
- Add `hl.exec_cmd('qs')` to your autostart function such as `/hypr/autostart.lua`
- Window rules from  `/hypr/quickshell.lua`, and keybinds to activate them

# Individual quirks
## OSD
The osd requires QtQuick.Studio.Components, which you will need to build yourself from this [github repo](https://github.com/qt-labs/qtquickdesigner-components)

## Wallpaper Picker
The picker uses [awww](https://codeberg.org/LGFae/awww), so awww-daemon has to be running for it to work. It also assumes your wallpapers are stored in $HOME/Pictures/Wallpapers, but you can change the srcDir variable in `/Wallpaper/WallpaperPicker.qml`

## Lockscreen
The lockscreen was built and tested on Fedora 44 with my pam configuration that supports fingerprint and password. I have no idea if it will behave correctly on other systems/pam configurations

# Note
- a lot of the looks of certain widgets depends on window rules in `/hypr/quickshell.lua` and may not function correctly without them
- All widgets are activated via ipc, examples are shown in `/hypr/quickshell.lua`
