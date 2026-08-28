import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../../config"

Item{
	id: root 
	property int boxSize: Boxes.boxSize
	property int rows: 4
	property int cols: 5
	property var boxes: []
	Component.onCompleted: boxes = Boxes.getBoxes(rows * cols)
	
	property string usageString: Icons.cpuIcon + String(SysInfo.usage).padStart(3, 0) + "%" 
	property string tempString: Icons.getTempIcon(SysInfo.temp) + String(SysInfo.temp).padStart(3, 0) + "󰔄" 
	property string ramString: Icons.ramIcon + String(SysInfo.ram).padStart(3, 0) + "%"

	width: boxSize * cols
	Layout.preferredHeight: parent.height
	Grid{
		id: grid
		anchors.fill: parent
		columns: cols
		rows: rows
		property int revealInd: mouse.containsMouse ? boxes.length : 0
		Behavior on revealInd {
			NumberAnimation { duration: 300 }
		}
		Repeater {
			model: cols * rows
			delegate: Rectangle {
				required property int index
				width: boxSize
				height: boxSize
				property int idx: boxes[index]
				color: (idx < grid.revealInd) ? Theme.accentPurpleHover : Theme.accentPurple
			}
		}
	}
	ColumnLayout{
		spacing: 0
		anchors.fill: parent
		Repeater{
			model: [usageString, tempString, ramString]
			delegate: Item{
				width: boxSize * 5
				height: (boxSize * 4-10) / 3
				Text{
					id: icon
					text: modelData[0]
					width: boxSize * 2
					anchors{
						top: parent.top
						bottom: parent.bottom
						left: parent.left
					}
					verticalAlignment: Text.AlignVCenter
					horizontalAlignment: Text.AlignHCenter
					font.family: Theme.fontIcon
				}
				Text{
					text: modelData.slice(1)
					font.family: Theme.fontFancy
					anchors{
						left: icon.right
						right: parent.right
						top: parent.top
						bottom: parent.bottom
					}
					verticalAlignment: Text.AlignVCenter
				}
			}
		}
	}
	
	MouseArea{
		id: mouse
		anchors.fill: parent
		hoverEnabled: true
		onClicked: Quickshell.execDetached(["hyprctl", "eval", "openBtop()"])
	}
}