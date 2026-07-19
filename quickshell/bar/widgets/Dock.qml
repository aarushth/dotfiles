import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects
import "../../config"

RowLayout{
	id: root
	required property int boxSize
	required property int maxRowNums
	required property var boxes
	required property int maxTotalBoxes
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
			property int revealInd: ws.active ? 0 : root.maxTotalBoxes
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
				onClicked: ws.activate()
			}
			Item{
				id: gridContainer
				anchors.fill: parent
				visible: false
				Grid{
					id: grid
					Layout.preferredWidth: parent.Layout.preferredWidth
					Layout.preferredHeight: parent.Layout.preferredHeight
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
			}
			Item{
				id: gridInverseContainer
				anchors.fill: parent
				visible: false
				Grid{
					id: gridInverse
					Layout.preferredWidth: parent.Layout.preferredWidth
					Layout.preferredHeight: parent.Layout.preferredHeight
					columns: wsBound.cols
					rows: root.maxRowNums
					Repeater {
						model: wsBound.totalBoxes
						delegate: Rectangle {
							required property int index
							width: root.boxSize
							height: root.boxSize
							property int idx: root.boxes[index % root.maxTotalBoxes]
							color: Theme.accentPurple
							opacity: (idx >= wsBound.revealInd) ? 1 : 0
						}
					}
				}
			}
			Item{
				id: iconContainer
				anchors.fill: parent
				visible: false
				ColumnLayout{
					spacing: 0
					Text{
						id: iconsText
						Layout.preferredHeight: root.boxSize * 3
						Layout.preferredWidth: wsBound.w
						text: modelData.toplevels.values.map(toplevel => Icons.get(toplevel.wayland?.appId?? "" ) ?? Icons.get(toplevel.title) ?? "").join(" ")
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
						font.pixelSize: root.boxSize * 2 - 2
						color: Theme.accentPurple
						font.family: "Symbols Nerd Font Mono"
					}
					Text{
						Layout.preferredHeight: root.boxSize
						Layout.preferredWidth: wsBound.w
						color: Theme.accentPurple
						text: modelData.name ?? modelData.id
						font.family: Theme.fontFancy
						font.bold: true
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignTop
					}
				}
			}
			OpacityMask {
				id: maskOne
				anchors.fill: parent
				source: gridContainer
				maskSource: iconContainer
				invert: true
			}
			OpacityMask {
				id: maskTwo
				anchors.fill: parent
				source: gridInverseContainer
				maskSource: iconContainer
			}
		}
	}
}
