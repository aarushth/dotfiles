# Basic setup

You will need these fonts:
+ [KH Interference TRIAL](https://khtype.com/typeface/kh-interference/)
+ [Specify Personal Extrexpanded](https://font.download/font/specify)
+ [PP Fraktion Mono](https://pangrampangram.com/products/fraktion-mono)
+ [Symbols Nerd Font](https://www.nerdfonts.com/font-downloads)

Other requirements:
+ [qt6 and its associated packages](https://www.qt.io/development/qt-framework/qt6)
+ [quickshell](https://quickshell.org/)

+ Add ```hl.exec_cmd('qs')``` to your autostart function such as ```/hypr/autostart.lua```

# Individual quirks
## OSD
The osd requires QtQuick.Studio.Components, which you will need to build yourself from this [github repo](https://github.com/qt-labs/qtquickdesigner-components)

## Wallpaper Picker
The picker uses [awww](https://codeberg.org/LGFae/awww), so awww-daemon has to be running for it to work. It also assumes your wallpapers are stored in $HOME/Pictures/Wallpapers, but you can change the srcDir variable in ```/Wallpaper/WallpaperPicker.qml```

## Lockscreen
The lockscreen was built and tested on Fedora 44 with my pam configuration that supports fingerprint and password. I have no idea if it will behave correctly on other systems/pam configurations

# Note
- a lot of the looks of certain widgets depends on window rules in ```/hypr/quickshell.lua``` and may not function correctly without them
- All widgets are activated via ipc, examples are shown in ```/hypr/quickshell.lua```
