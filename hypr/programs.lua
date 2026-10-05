---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
Terminal = "kitty"
FileManager = "yazi"
Menu = "qs ipc call start toggle"
-- Menu = "pkill rofi || rofi -show drun -show-icons"
TaskManager = "btop"
EmojiPicker = "rofimoji --action clipboard"
ScreenshotDir = "~/Pictures/Screenshots/"
SelectiveScreenshot = 'grim -g "$(slurp)" -t ppm - | satty -f - --actions-on-enter save-to-clipboard,exit --copy-command wl-copy --output-filename '
	.. ScreenshotDir
	.. "satty-$(date '+%Y%m%d-%H:%M:%S').png"
Screenshot = "grim -o \"$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')\" - | satty -f - --actions-on-enter save-to-clipboard,exit --copy-command wl-copy --output-filename "
	.. ScreenshotDir
	.. "test.png"
ClipboardManager = "clipse"
Browser = "firefox"
MonitorManager = "hyprmoncfg"
Lock = "loginctl lock-session"
WallpaperSwitcher = "qs ipc call wallpaper open"
WLogout = "qs ipc call wlogout toggle"
