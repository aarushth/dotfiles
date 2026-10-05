//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick
import "notifications"
import "osd"
import "wallpaper"
import "bar"
import "wlogout"
import "lockscreen"
import "start"

Scope {
    NotificationPopup {}
    Osd {}
    WallpaperPicker {}
    Bar {}
    WLogout {}
    Lockscreen {}
    Start {}
    IpcHandler {
        target: "main"

        function reload() {
            Quickshell.reload(true);
        }
    }
    //force qs to load all Desktop Entries so spotify doesn't end up null
    Component.onCompleted: {
        let entries = DesktopEntries;
    }
}
