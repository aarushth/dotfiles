import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../config/components"
import "../config/themes"

Scope {
    id: root
    property var theme: DefaultTheme {}
   
	FontLoader {
		id: specifypersonal
		source: "../config/fonts/SpecifyPERSONAL-ExExpBlack.ttf"
	}
	FontLoader {
		id: ppfraktionmono
		source: "../config/fonts/PPFraktionMono-Regular.woff2"
	}
    property int boxSize: 15
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

    Component.onCompleted: {
        initVals()
    }

    IpcHandler {
        target: "notifications"

        function dismiss_all() {
			for(let i = 0; i < NotificationService.notifications.length; i++){
				notifRepeater.itemAt(i).close()
			}
        }

        function dnd_toggle(){
            NotificationService.doNotDisturb = !NotificationService.doNotDisturb;
        }
		function dismiss_hovered(){
			for(let i = 0; i < NotificationService.notifications.length; i++){
				if(NotificationService.notifications[i].hovered){
					notifRepeater.itemAt(i).close()
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
		Item {
			id: notifCard
			required property var modelData;
			required property int index

			property bool closing: false
			property bool isImage: notifCard.modelData.image !== "" && notifImage.status === Image.Ready
			property int rowNums: 11 + (notifCard.modelData.actions.length > 0 ? 2 : 0)
			property int colNums: 24
			property int totalBoxes: rowNums * colNums
			property int cardHeight: rowNums * root.boxSize
			property int cardWidth: colNums * root.boxSize
			property var boxes: root.boxes.slice(0, totalBoxes)
			property color cardColor: notifCard.modelData.urgency === NotificationUrgency.Critical ? root.theme.urgencyCritical :
								notifCard.modelData.urgency === NotificationUrgency.Low ? root.theme.urgencyLow : root.theme.urgencyNormal
			
			function close(){
				if(!closing){
					grid.reset()
					closing = true
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
				HoverHandler {
					id: cardGridHover
					onHoveredChanged: notifCard.modelData.hovered = hovered
				}
				implicitWidth: notifCard.cardWidth
				implicitHeight: notifCard.cardHeight
				Grid {
					id: grid
					anchors.fill: parent
					columns: notifCard.colNums
					rows: notifCard.rowNums
					property int revealInd: 0
					property bool entering: true
					SequentialAnimation{
						id: entryAnim
						running: false
						NumberAnimation{
							target: grid
							property: "revealInd"
							from: 0; to: root.maxTotalBoxes
							duration: 500
							easing.type: Easing.OutCubic
							running: false
						}
						ScriptAction{ script: {notifWindow.visible = grid.entering} }
						NumberAnimation{
							target: grid
							property: "revealInd"
							from: root.maxTotalBoxes; to: 0
							duration: 500
							easing.type: Easing.OutCubic
							running: false
						}
						ScriptAction{ script: {
							squares.visible = false
							notifCard.modelData.timerStart = true
							entryAnim.stop()
							if(!grid.entering){
								notifCard.modelData.dismiss()
							}
						} }
					}
					function reset(){
						revealInd = 0
						squares.visible = true
						entering = false
						entryAnim.restart()
					}
					
					
					Repeater {
						model: notifCard.totalBoxes

						delegate: Rectangle {
							width: root.boxSize
							height: root.boxSize

							property int idx: 100000
							Component.onCompleted: idx = notifCard.boxes[index]
							color: notifCard.modelData.urgency === NotificationUrgency.Critical ? root.theme.urgencyCritical :
									notifCard.modelData.urgency === NotificationUrgency.Low ? root.theme.urgencyLow : root.theme.urgencyNormal

							opacity: (idx < grid.revealInd) ? 1 : 0
						}
					}
					Component.onCompleted: entryAnim.start()
				}
			}
			PanelWindow {
				id: notifWindow
				visible: false
				focusable: false
				color: "transparent"
				
				WlrLayershell.namespace: "quickshell-notification-card-blur"
				WlrLayershell.layer: WlrLayer.Top
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
							color: root.theme.bgBase
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
								if (name.includes("terminal") || name.includes("kitty") || name.includes("alacritty")) return "";
								return "󰂚";
							}

							color: root.theme.textPrimary
							font.pixelSize: 15
							font.family: ppfraktionmono.name
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
							color: root.theme.textPrimary
							font.pixelSize: 12
							font.family: ppfraktionmono.name
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
							color: root.theme.textPrimary
							font.pixelSize: closeHover.containsMouse ? 25 : 15
							font.family: root.font
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
							onClicked: grid.reset()
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
								// topMargin: 8
							}
							width: parent.width
							verticalAlignment: Text.AlignVCenter
							text: notifCard.modelData.appName
							color: root.theme.textSecondary
							font.pixelSize: 18
							font.family: specifypersonal.name
							font.capitalization: Font.AllUppercase
							font.bold: true
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
							color: root.theme.textMuted
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
							color: root.theme.textMuted
							width: parent.width
							font.family: ppfraktionmono.name
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
								color: root.theme.textPrimary
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
										script: {
											if(!notifCard.closing){
												grid.reset()
												notifCard.closing = true
											}
										}
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
							border.color: "#747275"
							radius: 3
							// visible: notifCard.modelData.urgency === NotificationUrgency.Critical
							Text{
								anchors.centerIn: parent
								width: parent.width
								height: parent.height

								horizontalAlignment: Text.AlignHCenter
								verticalAlignment: Text.AlignVCenter
								
								color: "#747275"
								text: "󰅖"
								font.family: root.font
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
							font.family: ppfraktionmono.name
							color: root.theme.textMuted
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
								anchors.fill: parent
								Rectangle {
									id: actionBtn
									required property var modelData
									required property int index

									anchors.verticalCenter: parent.verticalCenter
									width: notifCard.cardWidth/notifCard.modelData.actions.length
									height: parent.height
									opacity: 0.6
									color: actionHover.containsMouse ? root.theme.bgButtonHover : root.theme.bgButton
									Behavior on color {
										ColorAnimation { duration: 100 }
									}

									Accessible.role: Accessible.Button
									Accessible.name: actionBtn.modelData.text || ""

									Text {
										id: actionText
										anchors.centerIn: parent
										text: actionBtn.modelData.text || ""
										color: root.theme.textSecondary
										font.pixelSize: 11
										font.family: ppfraktionmono.name
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
		}
	}

}
