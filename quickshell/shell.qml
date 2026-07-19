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

Scope{
    NotificationPopup {}
    Osd{}
	WallpaperPicker {}
	Bar{}
	WLogout{}
	Lockscreen{}
}




