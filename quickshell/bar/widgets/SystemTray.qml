import QtQuick
import Quickshell
import Quickshell.Widgets
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.SystemTray
import "../../config"

RowLayout{
	id: root
	required property var window
	required property var boxSize
	spacing: 0
	Layout.preferredHeight: parent.height
	QsMenuOpener{
		id: menuOpener
	}
	PopupWindow {
		id: popup
		//min of 1 cuz menu loads items async, causing w/h to be set to 0 and crashes the whole qs process
		implicitWidth: Math.max(menuColumn.implicitWidth, 1)
		implicitHeight: Math.max(menuColumn.implicitHeight, 1)

		anchor {
			window: root.window
			edges: Edges.Top 
			gravity: Edges.Top
			rect.x: parentWindow.width
		}
		ColumnLayout {
			id: menuColumn
			anchors.fill: parent
			spacing: 0

			Repeater {
				model: menuOpener.children
				required property int index
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
		delegate: Rectangle {
			id: iconRoot
			width: boxSize * 2
			Layout.preferredHeight: parent.height
			color: Theme.accentPurple
			opacity: mouse.containsMouse ? 0.8 : 1
			Image { 
				source: modelData.icon; 
				anchors.centerIn: parent
				width: root.boxSize
				height: root.boxSize
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
