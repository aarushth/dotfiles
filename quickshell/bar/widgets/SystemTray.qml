import QtQuick
import Quickshell
import Quickshell.Widgets
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.SystemTray
import Quickshell.Hyprland
import "../../config"

Rectangle{
	id: tray
	required property var window
	property var boxSize: Boxes.boxSize
	implicitWidth: grid.implicitWidth
    implicitHeight: parent.height
	color: Theme.accentPurple
	property var boxes: []
	Component.onCompleted: boxes = Boxes.getBoxes(4)
	
	GridLayout{
		id: grid
		anchors.fill:parent
		rows: 2
		rowSpacing: 0
		columnSpacing: 0
		flow: GridLayout.TopToBottom
		Layout.preferredHeight: parent.height
		QsMenuOpener{
			id: menuOpener
		}
		HyprlandFocusGrab {
			id: grab
			windows: [popup]
			active: popup.backingWindowVisible
			onCleared: popup.visible = false
		}
		PopupWindow {
			id: popup
			implicitWidth: Math.max(menuColumn.implicitWidth, 1)
			implicitHeight: Math.max(menuColumn.implicitHeight, 1)

			anchor {
				window: tray.window
				item: tray
				edges: Edges.Top
				gravity: Edges.Top
			}
			ColumnLayout {
				id: menuColumn
				anchors.fill: parent
				spacing: 0

				Repeater {
					model: menuOpener.children
					property int index
					delegate: Rectangle {
						Layout.fillWidth: true
						Layout.preferredWidth: label.contentWidth + 20 // add padding
						Layout.preferredHeight: modelData.isSeparator ? 1 : 25

						color: modelData.isSeparator ? Theme.textMuted : (actionHover.containsMouse ? Theme.bgButton : Theme.bgButtonHover)
						RowLayout{
							anchors{
								verticalCenter: parent.verticalCenter
								left: parent.left
								leftMargin: 10
							}
							Image {
								source: modelData.icon
								fillMode: Image.PreserveAspectFit
								width: 15
								height: 15
								sourceSize: Qt.size(width, height)
								visible: modelData.icon !== ""
								opacity: modelData.enabled ? 1 : 0.4
							}
							Text {
								id: label
								color: Theme.textSecondary
								opacity: modelData.enabled ? 1 : 0.4
								text: modelData.text
								font.pixelSize: 12
								font.family: Theme.fontNormal
							}
						}
					
						MouseArea {
							id: actionHover
							anchors.fill: parent
							hoverEnabled: modelData.enabled
							cursorShape: Qt.PointingHandCursor
							onClicked: modelData.triggered()
						}
					}
				}
			}
		}
		Repeater {
			id: iconRepeater
			model: SystemTray.items
			delegate: Item{
				id: trayItem
				width: boxSize * 2
				height: boxSize * 2
				Grid{
					id: grid
					anchors.fill: parent
					columns: 2
					rows: 2
					property int revealInd: mouse.containsMouse ? boxes.length : 0
					Behavior on revealInd {
						NumberAnimation { duration: 200 }
					}
					Repeater {
						model: 4
						delegate: Rectangle {
							required property int index
							width: boxSize
							height: boxSize
							property int idx: boxes[index]
							color: (idx < grid.revealInd) ? Theme.accentPurpleHover : Theme.accentPurple
						}
					}
				}
				Image { 
					source: modelData.icon; 
					anchors.centerIn: parent
					width: boxSize * 1.2
					height: boxSize * 1.2
					asynchronous: true
				}
				MouseArea {
					id: mouse
					anchors.fill: parent
					hoverEnabled: true
					acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
					cursorShape: Qt.PointingHandCursor
					onClicked: (mouse) => {
						if (mouse.button === Qt.RightButton) {
							if(menuOpener.menu != modelData.menu){
								menuOpener.menu = modelData.menu
								popup.visible = true
							}else{
								popup.visible = !popup.visible
							}
						} else if(mouse.button === Qt.LeftButton){ 
							modelData.activate()
						} else if(mouse.button === Qt.MiddleButton){
							modelData.secondaryActivate()
						}
					}
				}
			}
		}
	}
}

