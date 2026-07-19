import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../config"

Scope {
    id: root
    property int boxSize: 12
    property int maxColNums: 24
    property int maxRowNums: 13
	property int maxTotalBoxes: maxColNums * maxRowNums
    property var boxes: []
    
    function initVals() {
        var temp = []
        boxes = new Array(maxTotalBoxes)
        
        for (let x = 0; x < maxColNums; x++) {
            for (let y = 0; y < maxRowNums; y++) {
                temp.push({
                    id: y * maxColNums + x,
                    score: Math.random()
                })
            }
        }
        temp.sort((a, b) => b.score - a.score)
        for (let i = 0; i < temp.length; i++) {
            boxes[temp[i].id] = i    
        }
        
    }

    Component.onCompleted: initVals()

    IpcHandler {
        target: "notifications"

        function dismiss_all() {
			NotificationService.dismissAll()
        }

        function dnd_toggle(){
            NotificationService.doNotDisturb = !NotificationService.doNotDisturb;
        }
		function dismiss_hovered(){
			for(let i = 0; i < NotificationService.notifications.length; i++){
				if(NotificationService.notifications[i].hovered){
					NotificationService.notifications[i].dismiss()
					return;
				}
			}
		}
    }
	Repeater {
		id: notifRepeater
		model: ScriptModel {
			values: NotificationService.notifications
			objectProp: "seqId"
		}
		property var heights : []
		onItemAdded: function(index, item) {
			if(heights.length == 0){
				heights.push(0)
			}else{
				heights.push(heights[index - 1] + notifRepeater.itemAt(index - 1).modelData.cardHeight)
			}
			item.modelData.yPos = heights[index] + (index + 1) * 10
		}
		onItemRemoved: function(index, item) {
			heights.splice(index, 1)
			for(let i = index; i < heights.length; i++){
				heights[i] = heights[i] - item.cardHeight
				notifRepeater.itemAt(i).modelData.yPos = heights[i] + (i + 1) * 10
			}
		}
		//single card
		delegate: Item {
			id: notifCard
			required property var modelData;
			required property int index
			property var triggerClose: modelData.triggerClose
			property bool closing: false
			property bool isImage: notifCard.modelData.image !== "" && notifImage.status === Image.Ready
			property int rowNums: 11 + (notifCard.modelData.actions.length > 0 ? 2 : 0)
			property int colNums: 24
			property int totalBoxes: rowNums * colNums
			property int cardHeight: rowNums * root.boxSize
			property int cardWidth: colNums * root.boxSize
			property var boxes: root.boxes.slice(0, totalBoxes)
			property color cardColor: notifCard.modelData.urgency === NotificationUrgency.Critical ? Theme.urgencyCritical :
								notifCard.modelData.urgency === NotificationUrgency.Low ? Theme.urgencyLow : Theme.urgencyNormal
			
			
			function beginCloseAnim(){
				if(!closing){
					grid.entryAnim.restart()
					closing = true
				}
			}
			onTriggerCloseChanged: {
				if(triggerClose){
					beginCloseAnim()
				}
			}
			
			
			PanelWindow {
				id: notifWindow
				visible: false
				focusable: false
				color: "transparent"
				WlrLayershell.namespace: "quickshell-notification-card-blur"
				WlrLayershell.layer: WlrLayer.Overlay
				WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
				exclusionMode: ExclusionMode.Ignore
				anchors {
					top: true
					right: true
				}

							
				implicitWidth: notifCard.cardWidth
				implicitHeight: notifCard.cardHeight
				margins {
					right: notifCard.modelData.hovered ? 30 : 10
					top: notifCard.modelData.yPos
				}  
				Behavior on margins.right{
					NumberAnimation {
						duration: 100
					}
				}
				Behavior on margins.top{
					NumberAnimation {
						duration: 400
						easing.type: Easing.InQuad 
					}
				}
				HoverHandler {
					id: cardHover
					onHoveredChanged: {notifCard.modelData.hovered = hovered}
					blocking: false
				}

				SimpleGrid{
					anchors.fill: parent
					columns: notifCard.colNums
					rows: notifCard.rowNums
					property int bodyColumnSpan: notifCard.colNums - (notifCard.isImage ? 9 : 2)
					//top bar background
					GridCell{
						gridColumn: 0
						gridRow: 0
						gridColumnSpan: notifCard.colNums
						gridRowSpan: 2
						Rectangle{
							anchors.fill:parent
							color: notifCard.cardColor

						}
					}
					//greybackground
					GridCell{
						gridColumn: 0
						gridRow: 2
						gridColumnSpan: notifCard.colNums
						gridRowSpan: notifCard.rowNums - 2
						opacity: 0.6
						Rectangle{
							anchors.fill:parent
							color: Theme.bgBase
						}
					}
					//icon
					GridCell{
						gridColumn: 0
						gridRow: 0
						gridColumnSpan: 2
						gridRowSpan: 2
						IconImage {
							anchors.centerIn: parent
							source: Quickshell.iconPath(notifCard.modelData.appIcon, true)
							implicitSize: root.boxSize * 2
							visible: notifCard.modelData.appIcon !== ""
						}

						Text {
							anchors.centerIn: parent
							visible: notifCard.modelData.appIcon === ""

							text: {
								const name = notifCard.modelData.appName.toLowerCase();
								if (notifCard.modelData.urgency === NotificationUrgency.Critical) return "󰀦";
								if (name.includes("discord"))  return "󰙯";
								if (name.includes("firefox"))  return "󰈹";
								if (name.includes("spotify"))  return "󰓇";
								if (name.includes("kitty"))  return "";
								return "󰂚";
							}

							color: Theme.textPrimary
							font.pixelSize: 15
							font.family: Theme.fontNormal
						}
					}
					//divider 
					GridCell{
						gridColumn: 2
						gridRow: 0
						gridColumnSpan: 1
						gridRowSpan: 2
						Rectangle{
							anchors {
								top: parent.top
								bottom: parent.bottom
							}
							width: 1
							color: "black"
						}
					}
					//app name
					GridCell{
						gridColumn: 2
						gridRow: 0
						gridColumnSpan: notifCard.colNums - 4
						gridRowSpan: 2
						Text {
							anchors{
								left: parent.left
								leftMargin: 10
								verticalCenter: parent.verticalCenter
							}
							verticalAlignment: Text.AlignVCenter
							font.capitalization: Font.Capitalize
							text: notifCard.modelData.summary || "Notification"
							color: Theme.textPrimary
							font.pixelSize: 12
							font.family: Theme.fontNormal
						}
					}
					//x button
					GridCell{
						id: xButton
						gridColumn: notifCard.colNums - 2
						gridRow: 0
						gridColumnSpan: 2
						gridRowSpan: 2

						Text {
							anchors.centerIn: parent
							text: "󰅖"
							color: Theme.textPrimary
							font.pixelSize: closeHover.containsMouse ? 25 : 15
							font.family: Theme.fontNormal
							Behavior on font.pixelSize {
								NumberAnimation {
									duration: 100
								}
							}
						}

						MouseArea {
							id: closeHover
							anchors.fill: parent
							hoverEnabled: true
							cursorShape: Qt.PointingHandCursor
							onClicked: notifCard.modelData.dismiss()
							// onHoveredChanged: 
						}
					}
					//notif title
					GridCell{
						gridRow: 2
						gridColumn: 1
						gridRowSpan: 3
						gridColumnSpan: notifCard.colNums - 2
						Text {
							anchors{
								verticalCenter: parent.verticalCenter
								left: parent.left
							}
							width: parent.width
							verticalAlignment: Text.AlignVCenter
							text: notifCard.modelData.appName
							color: Theme.textSecondary
							font.pixelSize: 18
							font.family: Theme.fontTitle
							font.styleName: "Black"
							font.capitalization: Font.AllUppercase
							elide: Text.ElideRight
							Layout.fillWidth: true
							visible: text !== ""
						}
					}
					//divider
					GridCell{
						gridRow: 4
						gridColumn: 1
						gridRowSpan: 1
						gridColumnSpan: notifCard.colNums - 2
						Rectangle{
							anchors{
								bottom: parent.bottom
								left: parent.left
								right: parent.right
							}
							height: 1
							opacity: 0.1
							color: Theme.textMuted
						}
					}
					//notif body text
					GridCell{
						gridRow: 6
						gridColumn: 1
						gridRowSpan: 2
						gridColumnSpan: notifCard.colNums - (notifCard.isImage ? 6 : 2)
						Rectangle{
							anchors.fill: parent
							color: "transparent"
						}
						Text {
							text: notifCard.modelData.body
							color: Theme.textMuted
							width: parent.width
							font.family: Theme.fontNormal
							wrapMode: Text.Wrap
							maximumLineCount: 2
							elide: Text.ElideRight
							Layout.fillWidth: true
							visible: text !== ""
							textFormat: Text.PlainText
						}
					}
					//notif body image
					GridCell{
						gridRow: 5
						gridColumn: notifCard.colNums - 5
						gridRowSpan: 4
						gridColumnSpan: 4
						Rectangle{
							anchors.fill: parent
							color: "transparent"
							visible: notifCard.isImage
							width: parent.width
							height: parent.height
							clip: true
							Image {
								id: notifImage
								// anchors.centerIn: parent
								width: parent.width - 10
								height: parent.height - 10
								anchors{
									right: parent.right
									verticalCenter: parent.verticalCenter
								}
								source: notifCard.modelData.image
								fillMode: Image.PreserveAspectCrop
								// sourceSize.width: 24
								// sourceSize.height: 24
							}
						}
					}
					//timer bar
					GridCell{
						gridRow: 9
						gridColumn: 0
						gridRowSpan: 2
						gridColumnSpan: notifCard.colNums
						Item{
							anchors.fill: parent
							Rectangle{
								anchors.fill: parent
								color: Theme.textPrimary
							}
							Rectangle {
								id: progressBar
								height: parent.height
								width: parent.width
								visible: notifCard.modelData.urgency !== NotificationUrgency.Critical
								radius: 1
								color: notifCard.cardColor
								opacity: 1
								Component.onCompleted: timer.start()
								SequentialAnimation {
									id: timer
									// running: true
									paused: !(notifCard.modelData.timerRunning)
									// PauseAnimation { duration: 50 }
									NumberAnimation {
										target: progressBar
										property: "width"
										to: 0
										duration: notifCard.modelData.timeOut
									}
									ScriptAction{
										script: notifCard.modelData.dismiss()
									}
								}
							}
						}
					}
					//press X
					GridCell{
						gridRow: 9
						gridColumn: 1
						gridRowSpan: 2
						gridColumnSpan: 2
						Rectangle{
							width: 14
							height: 14
							anchors{
								verticalCenter: parent.verticalCenter
								left: parent.left
							}
							color: "#272528"
							border.color: Theme.textSecondary
							radius: 3
							// visible: notifCard.modelData.urgency === NotificationUrgency.Critical
							Text{
								anchors.centerIn: parent
								width: parent.width
								height: parent.height

								horizontalAlignment: Text.AlignHCenter
								verticalAlignment: Text.AlignVCenter
								
								color: Theme.textSecondary
								text: "󰅖"
								font.family: Theme.fontNormal
							}
						}
					}
					//dismiss text
					GridCell{
						gridRow: 9
						gridColumn: 2
						gridRowSpan: 2
						gridColumnSpan: root.colNums - 4
						Text{
							anchors{
								verticalCenter: parent.verticalCenter
								left: parent.left
								leftMargin: 10
							}
							verticalAlignment: Text.AlignVCenter
							font.family: Theme.fontNormal
							color: Theme.textSecondary
							text: "Dismiss"
						}
					}
					//actions
					GridCell{
						gridRow: 11
						gridColumn: 0
						gridRowSpan: 2
						gridColumnSpan: notifCard.colNums
						RowLayout {
							width: parent.width
							height:parent.height
							uniformCellSizes: true
							spacing: 0
							
							visible: notifCard.modelData.actions.length > 0
							Repeater {
								model: notifCard.modelData.actions
								Layout.preferredWidth: parent.width
								Layout.preferredHeight: parent.height
								Rectangle {
									id: actionBtn
									required property var modelData
									required property int index

									// anchors.verticalCenter: parent.verticalCenter
									Layout.preferredWidth: notifCard.cardWidth/notifCard.modelData.actions.length
									Layout.preferredHeight: parent.height
									opacity: 0.6
									color: actionHover.containsMouse ? Theme.bgButtonHover : Theme.bgButton
									Behavior on color {
										ColorAnimation { duration: 100 }
									}

									Accessible.role: Accessible.Button
									Accessible.name: actionBtn.modelData.text || ""

									Text {
										id: actionText
										text: actionBtn.modelData.text || ""
										color: Theme.textSecondary
										verticalAlignment: Text.AlignVCenter
										horizontalAlignment: Text.AlignHCenter
										font.pixelSize: 11
										font.family: Theme.fontNormal
										width: parent.Layout.preferredWidth
										height: parent.Layout.preferredHeight
									}

									MouseArea {
										id: actionHover
										anchors.fill: parent
										hoverEnabled: true
										cursorShape: Qt.PointingHandCursor
										onClicked: notifCard.modelData.invokeAction(actionBtn.modelData.identifier)
									}
									Rectangle{
										anchors {
											top: parent.top
											bottom: parent.bottom
											right: parent.right
										}
										color: "black"
										visible: parent.index + 1 < notifCard.modelData.actions.length
										width: 1
									}
								}
							}
						}
					}      

				}                    
			}
			PanelWindow{
				id: squares
				focusable: false
				color: "transparent"
				WlrLayershell.namespace: "quickshell-notification-card"
				WlrLayershell.layer: WlrLayer.Overlay
				WlrLayershell.keyboardFocus: WlrKeyboardFocus.None 
				anchors {
					top: true
					right: true
				}

				margins {
					right: notifCard.modelData.hovered ? 30 : 10
					top: notifCard.modelData.yPos
				}  
				implicitWidth: notifCard.cardWidth
				implicitHeight: notifCard.cardHeight
				Behavior on margins.right{
					NumberAnimation {
						duration: 100
					}
				}
				Behavior on margins.top{
					NumberAnimation {
						duration: 400
						easing.type: Easing.InQuad 
					}
				}
				HoverHandler {
					id: cardGridHover
					onHoveredChanged: notifCard.modelData.hovered = hovered
				}
				
				Grid {
					id: grid
					anchors.fill: parent
					columns: notifCard.colNums
					rows: notifCard.rowNums
					property int revealInd: 0
					property var entryAnim: SequentialAnimation{
						id: entryAnim
						running: false
						ScriptAction{
							script:{
								grid.revealInd = 0
								squares.visible = true
							}
						}
						NumberAnimation{
							target: grid
							property: "revealInd"
							from: 0; to: root.maxTotalBoxes
							duration: 500
							running: false
						}
						PauseAnimation{ duration: 100 }
						ScriptAction{ script: {notifWindow.visible = !notifCard.closing} }
						NumberAnimation{
							target: grid
							property: "revealInd"
							from: root.maxTotalBoxes; to: 0
							duration: 500
							running: false
						}
						ScriptAction{ 
							script: {
								squares.visible = false
								notifCard.modelData.timerStart = true
								entryAnim.stop()
								if(notifCard.closing){
									notifCard.modelData.completeDismiss()
								}
							}
						}
					}
					
					Repeater {
						model: notifCard.totalBoxes

						delegate: Rectangle {
							width: root.boxSize
							height: root.boxSize

							property int idx: 100000
							Component.onCompleted: idx = notifCard.boxes[index]
							color: notifCard.cardColor
							opacity: (idx < grid.revealInd) ? 1 : 0
						}
					}
					Component.onCompleted: entryAnim.start()
				}
			}
		}
	}

}
