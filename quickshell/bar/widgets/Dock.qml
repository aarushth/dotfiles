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
	required property int boxSize
	required property int maxRowNums
	required property var boxes
	required property int maxTotalBoxes
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
			property var totalBoxes: cols * root.maxRowNums
			Layout.preferredHeight: parent.height
			Layout.preferredWidth: w
			color: "transparent"
			property int revealInd: activeWsId == ws.id ? 0 : root.maxTotalBoxes
			property int mouseRevealInd: mouse.containsMouse ? 0 : root.maxTotalBoxes
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
				rows: root.maxRowNums
				
				Repeater {
					model: wsBound.totalBoxes
					delegate: Rectangle {
						required property int index
						width: root.boxSize
						height: root.boxSize
						property int idx: root.boxes[index % root.maxTotalBoxes]
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
					text: modelData.toplevels.values.map(toplevel => Icons.get(toplevel.wayland?.appId?? "" ) ?? Icons.get(toplevel.title) ?? "").join(" ")
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					font.pixelSize: root.boxSize * 2 - 2
					color: Theme.accentPurple
					font.family: "Symbols Nerd Font Mono"
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
