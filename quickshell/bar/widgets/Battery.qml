// import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../../config"

Rectangle{
	id: root
	property int boxSize: Boxes.boxSize
	property int cols: 4
	property int rows: 4
	property var boxes: []
	Component.onCompleted: boxes = Boxes.getBoxes(rows * cols)
	property var battery: UPower.displayDevice
	property string batteryPercentage: String(Math.round(battery.percentage * 100)).padStart(3, 0) + "%"
	property string batteryIcon: battery.state == UPowerDeviceState.Charging ? Icons.batteryChargingIcons[Math.round(battery.percentage * 10)] : Icons.batteryIcons[Math.round(battery.percentage * 10)]
	property string powerProfileIcon: Icons.powerProfileIcons.get(PowerProfile.toString(PowerProfiles.profile))
	function cyclePowerProfile(){
		PowerProfiles.profile = PowerProfile.toString((PowerProfiles.profile + 1) % 3)
	}
	readonly property color batteryTextColor: batteryPercentage <= 0.15 ? Theme.accentRed : Theme.bgBase
	
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
		onClicked: cyclePowerProfile()
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
			text: root.batteryIcon + " " + root.powerProfileIcon
			font.family: Theme.fontIcon
			color: batteryTextColor
		}
		Text{
			Layout.preferredWidth: parent.width
			Layout.preferredHeight: root.boxSize * rows/2
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			font.pixelSize: 15
			text: batteryPercentage
			font.family: Theme.fontFancy
			color: batteryTextColor
		}
	}
}
