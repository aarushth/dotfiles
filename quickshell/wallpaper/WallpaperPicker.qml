import QtQuick
import Quickshell
import Quickshell.Io

Scope{
    id: root
	property string windowClass: "WallpaperPicker"
    property bool shouldShowPicker : false


	IpcHandler {
		target: "wallpaper"

		function show() {
			root.shouldShowPicker = true
		}
		function hide(){
			root.shouldShowPicker = false
		}
		function toggle(){
			root.shouldShowPicker = !root.shouldShowPicker
		}
	}
    LazyLoader {
		active: root.shouldShowPicker
		FloatingWindow{
			Text{
				text: "hello I am under the water"
			}
		}
    }
}