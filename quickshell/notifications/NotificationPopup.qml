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
	Item {
		id: notifRepeaterHost
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
				heights.push(heights[index - 1] + notifRepeater.itemAt(index - 1).notificationData.cardHeight)
			}
			item.notificationData.yPos = heights[index] + (index + 1) * 10
		}
		onItemRemoved: function(index, item) {
			heights.splice(index, 1)
			for(let i = index; i < heights.length; i++){
				heights[i] = heights[i] - item.cardHeight
				notifRepeater.itemAt(i).notificationData.yPos = heights[i] + (i + 1) * 10
			}
		}
		delegate: Item {
			id: notifCard
			required property NotificationData modelData
            property NotificationData notificationData: modelData
			required property int index
			property var triggerClose: notificationData.triggerClose
			property bool closing: false
			property bool isImage: notificationData.image !== "" && notifImage.status === Image.Ready
			property int rowNums: 11 + (notificationData.actions.length > 0 ? 2 : 0)
			property int colNums: 24
			property int totalBoxes: rowNums * colNums
			property int cardHeight: rowNums * root.boxSize
			property int cardWidth: colNums * root.boxSize
			property var boxes: root.boxes.slice(0, totalBoxes)
			property color cardColor: notificationData.urgency === NotificationUrgency.Critical ? Theme.urgencyCritical :
								notificationData.urgency === NotificationUrgency.Low ? Theme.urgencyLow : Theme.urgencyNormal
			
			onTriggerCloseChanged: {
				if(triggerClose && !closing){
					for (const item of variants.instances) {
						item.beginCloseAnim()
					}
					closing = true
				}
			}
			
			Variants{
				id: variants
				model: Quickshell.screens
				delegate: Item{
					required property var modelData
					function beginCloseAnim() {
						grid.entryAnim.restart()
					}
					
					PanelWindow{
						id: squares
						screen: modelData
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
							right: notifCard.notificationData.hovered ? 30 : 10
							top: notifCard.notificationData.yPos?? 0
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
							onHoveredChanged: notifCard.notificationData.hovered = hovered
						}
						
						Item {
							id: grid
							anchors.fill: parent
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
										if(notificationData.urgency !== NotificationUrgency.Critical){
											notificationData.timer.start()
										}
										if(notifCard.closing){
											notifCard.notificationData.completeDismiss()
										}
									}
								}
							}
							Component.onCompleted: entryAnim.start()
							Repeater {
								model: notifCard.totalBoxes

								delegate: Rectangle {
									x: (index % notifCard.colNums) * root.boxSize
									y: Math.floor(index / notifCard.colNums) * root.boxSize
									width: root.boxSize
									height: root.boxSize
									property int idx: notifCard.boxes[index]
									color: notifCard.cardColor
									opacity: (idx < grid.revealInd) ? 1 : 0
								}
							}
							
						}
					}
					PanelWindow {
						id: notifWindow
						screen: modelData
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
							right: notifCard.notificationData.hovered ? 30 : 10
							top: notifCard.notificationData.yPos
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
							onHoveredChanged: {notifCard.notificationData.hovered = hovered}
							blocking: false
						}
						Rectangle{
							id: topBackground
							anchors{
								top: parent.top
								left: parent.left
								right: parent.right
							}
							height: root.boxSize * 2
							color: notifCard.cardColor
						}
						Rectangle{
							anchors{
								top: topBackground.bottom
								left: parent.left
								right: parent.right
								bottom: parent.bottom
							}
							color: Theme.bgBase
							opacity: 0.6
						}
						Text {
							id: icon
							anchors{
								top: parent.top
								left: parent.left
							}
							verticalAlignment: Text.AlignVCenter
							horizontalAlignment: Text.AlignHCenter
							width: root.boxSize * 2
							height: boxSize * 2
							text: Icons.get(notifCard.notificationData.appName.toLowerCase()) ?? "󰂚"
							color: Theme.textPrimary
							font.pixelSize: 12
							font.family: Theme.fontIcon
						}
						Rectangle{
							id: divider
							anchors {
								top: icon.top
								left: icon.right
								bottom: icon.bottom
							}
							width: 1
							color: "black"
						}
						Text {
							id: appName
							anchors{
								top: divider.top
								bottom: divider.bottom
								left: divider.right
								right: parent.right
								leftMargin: 10
							}
							verticalAlignment: Text.AlignVCenter
							font.capitalization: Font.Capitalize
							text: notifCard.notificationData.summary || "Notification"
							color: Theme.textPrimary
							font.pixelSize: 12
							font.family: Theme.fontNormal
						}
						Item{
							anchors{
								top: appName.top
								bottom: appName.bottom
								right: parent.right
							}
							width: boxSize * 2
							Text {
								anchors.fill: parent
								verticalAlignment: Text.AlignVCenter
								horizontalAlignment: Text.AlignHCenter
								text: "󰅖"
								color: Theme.textPrimary
								font.pixelSize: closeHover.containsMouse ? 15 : 10
								font.family: Theme.fontIcon
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
								onClicked: notifCard.notificationData.dismiss()
							}
						}
						Text {
							id: title
							anchors{
								top: appName.bottom
								left: parent.left
								right: parent.right
								leftMargin: boxSize
								rightMargin: boxSize
							}
							height: boxSize * 3
							verticalAlignment: Text.AlignVCenter
							text: notifCard.notificationData.appName
							color: Theme.textSecondary
							font.pixelSize: 18
							font.family: Theme.fontTitle
							font.styleName: "Black"
							font.capitalization: Font.AllUppercase
							elide: Text.ElideRight
							Layout.fillWidth: true
							visible: text !== ""
						}
						Rectangle{
							anchors{
								top: title.bottom
								left: title.left
								right: title.right
							}
							height: 1
							opacity: 0.1
							color: Theme.textMuted
						}
						Text {
							anchors{
								top: title.bottom
								left: parent.left
								topMargin: boxSize / 4
								leftMargin: boxSize
								rightMargin: boxSize
							}
							text: notifCard.notificationData.body
							color: Theme.textMuted
							height: boxSize * 4
							width: (notifCard.colNums - (notifCard.isImage ? 6 : 2)) * boxSize 
							font.family: Theme.fontNormal
							font.pixelSize: 11
							wrapMode: Text.Wrap
							maximumLineCount: 3
							elide: Text.ElideRight
							visible: text !== ""
						}
						Rectangle{
							anchors{
								top: title.bottom
								right: parent.right
								rightMargin: boxSize
							}
							color: "transparent"
							visible: notifCard.isImage
							width: boxSize * 4
							height: boxSize * 4
							clip: true
							Image {
								id: notifImage
								width: parent.width - 10
								height: parent.height - 10
								anchors{
									right: parent.right
									verticalCenter: parent.verticalCenter
								}
								source: notifCard.notificationData.image
								fillMode: Image.PreserveAspectCrop
							}
						}
						Item{
							anchors{
								left: parent.left
								right: parent.right
								bottom: actions.visible ? actions.top : parent.bottom
							}
							height: boxSize * 2
							Rectangle{
								anchors.fill: parent
								color: Theme.textPrimary
							}
							Rectangle {
								id: progressBar
								height: parent.height
								width: parent.width * notificationData.timerValue / notificationData.expireTimeout
								visible: notifCard.notificationData.urgency !== NotificationUrgency.Critical
								radius: 1
								color: notifCard.cardColor
								opacity: 1
							}
							Rectangle{
								id: xIcon
								width: 14
								height: 14
								anchors{
									verticalCenter: progressBar.verticalCenter
									left: progressBar.left
									leftMargin: boxSize
								}
								color: Theme.bgBase
								border.color: Theme.textSecondary
								radius: 3
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
							Text{
								anchors{
									top: progressBar.top
									bottom: progressBar.bottom
									left: xIcon.right
									leftMargin: boxSize
								}
								verticalAlignment: Text.AlignVCenter
								font.family: Theme.fontNormal
								color: Theme.textSecondary
								text: "Dismiss"
							}
						}
						RowLayout {
							id: actions
							anchors{
								bottom: parent.bottom
								left: parent.left
								right: parent.right
							}
							height: boxSize * 2
							uniformCellSizes: true
							spacing: 0
							visible: notifCard.notificationData.actions.length > 0
							Repeater {
								model: notifCard.notificationData.actions
								Layout.preferredWidth: parent.width
								Layout.preferredHeight: parent.height
								Rectangle {
									id: actionBtn
									property var action: modelData
									required property int index
									Layout.preferredWidth: notifCard.cardWidth/notifCard.notificationData.actions.length
									Layout.preferredHeight: parent.height
									opacity: 0.6
									color: actionHover.containsMouse ? Theme.bgButtonHover : Theme.bgButton
									Behavior on color {
										ColorAnimation { duration: 100 }
									}
									Text {
										id: actionText
										text: action.text || ""
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
										onClicked: notifCard.notificationData.invokeAction(action.identifier)
									}
									Rectangle{
										anchors {
											top: parent.top
											bottom: parent.bottom
											right: parent.right
										}
										color: "black"
										visible: parent.index + 1 < notifCard.notificationData.actions.length
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
}
