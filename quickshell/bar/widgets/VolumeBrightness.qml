import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../config"

ColumnLayout{	
	id: root	
	spacing: 0
	required property int boxSize
	required property var boxes
	Layout.preferredHeight: parent.height
	required property int cols
	required property int rows
	width: boxSize * cols
	property string volume: String(Math.round(OsdData.volume * 100))
	property string brightness: String(Math.round(OsdData.brightness * 100))
	property string volumeText: Icons.getVolumeIcon(volume, OsdData.muted) + " " + volume.padStart(3, "0") + "%"
	property string brightnessText:  Icons.brightnessIcons[Math.ceil(brightness / 10)] + " " + brightness.padStart(3, "0") + "%"
	Repeater{
		model:[root.volumeText, root.brightnessText]
		delegate: Rectangle{
			Layout.fillWidth: true
			Layout.fillHeight: true
			Grid{
				id: grid
				anchors.fill: parent
				columns: root.cols
				rows: root.rows/2
				property int revealInd: mouse.containsMouse ? root.boxes.length : 0
				Behavior on revealInd {
					NumberAnimation { duration: 300 }
				}
				Repeater {
					model: root.cols * root.rows / 2
					delegate: Rectangle {
						required property int index
						width: root.boxSize
						height: root.boxSize
						property int idx: root.boxes[index]
						color: (idx < grid.revealInd) ? Theme.accentPurpleHover : Theme.accentPurple
					}
				}
			}
			MouseArea{
				id: mouse
				anchors.fill: parent
				hoverEnabled: true
				onClicked: index == 0 ? OsdData.showVolume() : OsdData.showBrightness()
			}
			Text{
				anchors.fill: parent
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				text: modelData
				font.family: Theme.fontNormal || "Symbols Nerd Font Mono"
				font.pixelSize: 14
				color: OsdData.muted && index == 0 ? Theme.textMuted : Theme.bgBase
			}
			
			
		}
	}
}
