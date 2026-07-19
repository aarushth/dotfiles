import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import "../config"

Scope{
	id: root
	property int boxSize: 32
	property bool shouldShowWLogout: false
	property int rows: 2
	property int cols: 8
	property int totalBoxes: rows * cols
	property var boxes: []
	property list<LogoutButton> buttons: [ 
			LogoutButton {
				command: "loginctl lock-session"
				text: "Lock"
				icon: ""
			},
			LogoutButton {
				command: "loginctl terminate-user $USER"
				text: "Logout"
				icon: "󰍃"
			},
			LogoutButton {
				command: "systemctl poweroff"
				text: "Shutdown"
				icon: ""
			},
			LogoutButton {
				command: "systemctl reboot"
				text: "Reboot"
				icon: "󰑐"
			},
		]
	property int selectedIndex: 0
	IpcHandler {
		target: "wlogout"

		function toggle() {
			shouldShowWLogout = !shouldShowWLogout
		}
	}
	Component.onCompleted: initVals()
	function initVals(){
        var temp = []
        boxes = new Array(totalBoxes)
        
        for (let x = 0; x < cols; x++) {
            for (let y = 0; y < rows; y++) {
                temp.push({
                    id: y * cols + x,
                    score: Math.random()
                })
            }
        }
        temp.sort((a, b) => b.score - a.score)
        for (let i = 0; i < temp.length; i++) {
            boxes[temp[i].id] = i    
        }
	}
	LazyLoader {
		active: shouldShowWLogout
		PanelWindow {
			exclusionMode: ExclusionMode.Ignore
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
			WlrLayershell.namespace: "quickshell-wlogout"
			color: "transparent"

			contentItem {
				focus: true
				Keys.onPressed: event => {
					if (event.key == Qt.Key_Escape) {
						shouldShowWLogout = false
					}else if (event.key == Qt.Key_Down || event.key == Qt.Key_S){
						selectedIndex = (selectedIndex + 1)% buttons.length
					}else if(event.key == Qt.Key_Up || event.key == Qt.Key_W){
						selectedIndex = ((selectedIndex - 1) % buttons.length + buttons.length) % buttons.length
					}else if(event.key == Qt.Key_Return){
						buttons[selectedIndex].exec()
						root.shouldShowWLogout = false
					}
				}
			}

			anchors {
				top: true
				left: true
				bottom: true
				right: true
			}

			Rectangle {
				color: Theme.bgBase
				anchors.fill: parent
				opacity: 0.9
				MouseArea {
					anchors.fill: parent
					onClicked: root.shouldShowWLogout = false
				}
				Item{
					anchors.centerIn: parent
					width: root.boxSize * cols
					height: root.boxSize * rows * root.buttons.length
					Rectangle{
						id: rectClip
						anchors.fill: parent
						radius: 20
						visible: false
					}	
					ColumnLayout{
						id: buttonLayout
						anchors.fill: parent
						opacity: 0
						spacing: 0
						Repeater {
							model: buttons
							delegate: Item{
								required property LogoutButton modelData
								required property int index
								property color textColor:Theme.textMuted
								Layout.preferredWidth: root.boxSize * cols
								Layout.preferredHeight: root.boxSize * rows
								Item{
									id: text
									anchors.fill: parent
									visible: false
									Text {
										id: icon
										anchors{
											top: parent.top
											bottom: parent.bottom
											left: parent.left
										}
										width: root.boxSize * 2
										text: modelData.icon
										font.pointSize: 18
										color: textColor
										verticalAlignment: Text.AlignVCenter
										horizontalAlignment: Text.AlignHCenter
										font.family: "Symbols Nerd Font Mono"
									}
									Rectangle{
										id: divider
										anchors{
											top: parent.top
											bottom: parent.bottom
											left: icon.right
										}
										width: 1
										color: Theme.bgBase
									}
									Text {
										id: label
										anchors{
											top: parent.top
											bottom: parent.bottom
											left: divider.right
											right: parent.right
											leftMargin: root.boxSize / 2
										}
										text: modelData.text
										font.pointSize: 18
										color: textColor
										verticalAlignment: Text.AlignVCenter
										font.family: Theme.fontNormal
									}
								}
								Grid{
									id: gridSelect
									rows: root.rows
									columns: root.cols
									visible: false
									anchors.fill: parent
									property int revealInd: parent.index == root.selectedIndex ? root.totalBoxes : 0
									Behavior on revealInd{
										NumberAnimation{ duration: 200 }
									}
									Repeater {
										model: root.totalBoxes
										delegate: Rectangle {
											required property int index
											width: boxSize
											height: boxSize
											property int idx: root.boxes[index]
											color: Theme.accentPurple
											opacity: idx < gridSelect.revealInd ? 1 : 0
										}
									}
								}
								MouseArea {
									id: mouse
									anchors.fill: parent
									hoverEnabled: true
									onClicked: {
										selectedIndex = index
										anim.restart()
									}
									Timer{
										id: anim
										interval: 300
										onTriggered: {
											modelData.exec()
											root.shouldShowWLogout = false
										}
									}
								}
								OpacityMask{
									anchors.fill: parent
									source: gridSelect
									maskSource:  text
									invert: true
								}
								OpacityMask{
									anchors.fill: parent
									source: text
									maskSource:  gridSelect
									invert: true
								}
								Grid{
									id: grid
									rows: root.rows
									columns: root.cols
									property int revealInd: mouse.containsMouse ? 0 : root.totalBoxes
									Behavior on revealInd{
										NumberAnimation{ duration: 200 }
									}
									Repeater {
										model: root.totalBoxes
										delegate: Rectangle {
											required property int index
											width: boxSize
											height: boxSize
											property int idx: boxes[index]
											color: Theme.bgButton
											opacity: (idx < grid.revealInd) ? 0 : 0.3
										}
									}
								}	
							}
						}
					}
					Item{
						anchors{
							right: parent.left
							rightMargin: root.boxSize / 4
							top: parent.top
							topMargin: root.boxSize * 2 * selectedIndex
						}
						height: root.boxSize * 2
						width: root.boxSize * 2
						ColumnLayout{
							anchors{
								verticalCenter: parent.verticalCenter
								right: parent.right
							}
							Repeater{
								model: ["W", "S"]
								delegate: Rectangle{
									width: root.boxSize - 12
									height: root.boxSize - 12
									color: "#272528"
									border.color: Theme.textMuted
									radius: 3
									// visible: notifCard.modelData.urgency === NotificationUrgency.Critical
									Text{
										anchors.centerIn: parent
										width: parent.width
										height: parent.height

										horizontalAlignment: Text.AlignHCenter
										verticalAlignment: Text.AlignVCenter
										
										color: Theme.textMuted
										text: modelData
										font.family: Theme.fontNormal
									}
								}
							}
						}
					}
					OpacityMask {
						anchors.fill: parent
						source: buttonLayout
						maskSource: rectClip
					}
				}
				
			}
		}
	}
}
