import Quickshell
import Quickshell.Widgets
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import "../../config"

Rectangle{
	id: root
	required property int boxSize
	required property int cols
	required property int rows
	required property var boxes
	property var battery: UPower.displayDevice
	property string batteryIcon: battery.state == UPowerDeviceState.Charging ? Icons.batteryChargingIcons[Math.round(battery.percentage * 10)] : Icons.batteryIcons[Math.round(battery.percentage * 10)]

	property string powerProfileIcon: Icons.powerProfileIcons.get(PowerProfile.toString(PowerProfiles.profile))
	
	property color textColor: battery.percentage <= 0.15 ? Theme.accentRed : Theme.bgBase
	implicitHeight: parent.height
	width: root.boxSize * cols
	color: Theme.accentPurple
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
	MouseArea{
		id: mouse
		anchors.fill: parent
		hoverEnabled: true
		onClicked: PowerProfiles.profile = PowerProfile.toString((PowerProfiles.profile + 1) % 3)
	}
	ColumnLayout{
		anchors.fill: parent
		spacing: 0
		Text{
			Layout.preferredWidth: parent.width
			Layout.preferredHeight: boxSize * rows/2
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignBottom
			font.pixelSize: 15
			text: batteryIcon + " " + powerProfileIcon
			font.family: "Symbols Nerd Font"
			color: textColor
		}
		Text{
			Layout.preferredWidth: parent.width
			Layout.preferredHeight: root.boxSize * rows/2
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			font.pixelSize: 15
			text: String(Math.round(battery.percentage * 100)).padStart(3, 0) + "%"
			font.family: Theme.fontFancy
			color: textColor
		}
	}
}
