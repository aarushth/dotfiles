import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../config"
Item{
	id: idle
	property int boxSize: Boxes.boxSize
	required property var window
	width: boxSize * 4
	height: boxSize * 4
	property var boxes: []
	Component.onCompleted: boxes = Boxes.getBoxes(16)
	property int revealIndex: mouseArea.containsMouse ? boxes.length : 0
	Behavior on revealIndex{
		NumberAnimation{ duration: 300 }
	}
	Grid{
		rows: 4
		Repeater{
			model: 16
			delegate: Rectangle{
				width: boxSize
				height: boxSize
				color: revealIndex > idx ? Theme.accentPurpleHover : Theme.accentPurple
				property int idx: boxes[index]
			}
		}
	}
	Text{
		anchors.fill: parent
		verticalAlignment: Text.AlignVCenter
		horizontalAlignment: Text.AlignHCenter
		font.family: Theme.fontIcon
		font.pixelSize: 25
		text: SysInfo.inhibiting ? Icons.wakeIcon : Icons.sleepIcon
	}
	
	
	
	MouseArea{
		id: mouseArea
		anchors.fill: parent
		hoverEnabled: true
		onClicked: SysInfo.inhibiting = !SysInfo.inhibiting
	}
	IdleInhibitor{
		window: idle.window
		enabled: SysInfo.inhibiting
	}
}