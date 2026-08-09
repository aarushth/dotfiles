import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../config"
Rectangle{
	id: idle
	required property int boxSize
	required property var window
	width: boxSize * 4
	height: boxSize * 4
	color: SysInfo.inhibiting ? Theme.accentPurpleHover : Theme.accentPurple
	MouseArea{
		anchors.fill: parent
		onClicked: SysInfo.inhibiting = !SysInfo.inhibiting
	}
	IdleInhibitor{
		window: idle.window
		enabled: SysInfo.inhibiting
	}
}