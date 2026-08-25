import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../../config"

RowLayout{
	id: root
	property int boxSize: Boxes.boxSize
	property int rows: 4
	required property int activeWsId
	Layout.preferredHeight: parent.height
	spacing: 0
	Repeater {
		model: Hyprland.workspaces
		delegate: Rectangle{
			id: wsBound
			property var ws: modelData
			property var cols: (ws.toplevels.values.length * 3) + 1
			property var w: (cols) * root.boxSize
			property var totalBoxes: cols * 4
			property var boxes: []
			onTotalBoxesChanged: boxes = Boxes.getBoxes(totalBoxes)
			Layout.preferredHeight: parent.height
			Layout.preferredWidth: w
			color: "transparent"
			property int revealInd: activeWsId == ws.id ? 0 : totalBoxes
			property int mouseRevealInd: mouse.containsMouse ? 0 : totalBoxes
			visible: ws.toplevels.values.length > 0
			Behavior on revealInd {
				NumberAnimation { duration: 200 }
			}
			Behavior on mouseRevealInd {
				NumberAnimation { duration: 200 }
			}
			MouseArea{
				id: mouse
				anchors.fill:parent
				hoverEnabled: true
				readonly property var process: Process {
					command: ["hyprctl", "dispatch", `hl.dsp.focus({ workspace = "name:${ws.name}", on_current_monitor = true})`]
				}
				onClicked: process.startDetached()
			}

			Grid{
				id: grid
				visible: false
				anchors.fill: parent
				columns: wsBound.cols
				rows: 4
				Repeater {
					model: wsBound.totalBoxes
					delegate: Rectangle {
						required property int index
						width: root.boxSize
						height: root.boxSize
						property int idx: boxes[index] ?? 0
						color: (idx < wsBound.mouseRevealInd) ? Theme.accentPurple : Theme.accentPurpleHover
						opacity: (idx < wsBound.revealInd) ? 1 : 0
					}
				}
			}	
			Item{
				id: iconContainer
				anchors.fill: parent
				visible: false
				Text{
					id: iconsText
					anchors{
						top: parent.top
						left: parent.left
						right: parent.right
					}
					height: root.boxSize * 3
					text: modelData.toplevels.values.map(toplevel => Icons.get(toplevel.lastIpcObject.class?? toplevel.title ) ?? Icons.get(toplevel.wayland?.appId) ?? "").join(" ")
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					font.pixelSize: root.boxSize * 2 - 2
					color: Theme.accentPurple
					font.family: Theme.fontIcon
				}
				Text{
					anchors{
						bottom: parent.bottom
						left: parent.left
						right: parent.right			
						bottomMargin: 1				
					}
					color: Theme.accentPurple
					text: modelData.name ?? modelData.id
					font.family: Theme.fontFancy
					font.bold: true
					font.pixelSize: 14
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignTop
				}
			}
			OpacityMask {
				anchors.fill: parent
				source: grid
				maskSource: iconContainer
				invert: true
			}
			OpacityMask {
				anchors.fill: parent
				source: iconContainer
				maskSource: grid
				invert: true
			}
		}
	}
}
