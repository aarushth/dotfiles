import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell
import Qt5Compat.GraphicalEffects
import Quickshell.Io
// import Quickshell.DBus
import "../config"
Item {
	id: root
	required property LockContext context
	property string displayText: "SYSTEM LOCKED"
	Timer {
		id: resetTimer
		interval: 1000
		repeat: false
		onTriggered: {
			opacityMask.invert = false
			if (context.message === "Place your right index finger on the fingerprint reader"){
				displayText = "SCAN 󰈷 FINGERPRINT"
			}else if(context.message === "Password: "){
				displayText = ""
			}else{
				context.restart()
				displayText = "SYSTEM LOCKED"
			}
		}
	}
	property int timeout: 60	
	Timer {
        id: suspendTimer
        interval: timeout * 1000
        running: true
		repeat: true
        onTriggered: {
			suspend.startDetached();
			countdown.restart()
			context.restart()
        }
    }
	readonly property var suspend: Process {
		command: ["sh", "-c", "systemctl suspend"]
	}
	property int timer: 0
	
	NumberAnimation{
		id: countdown
		running: true
		from: timeout
		to: 0
		duration: timeout*1000
		target: root
		property: "timer"
	}
	Connections {
		target: context

		function onMessageChanged() {
			switch (context.message) {
				case "Failed to match fingerprint":
					opacityMask.invert = true
					resetTimer.restart()
					displayText = "ACCESS DENIED"
					break
				case "":
					opacityMask.invert = true
					resetTimer.restart()
					displayText = "VERIFYING"
					break

				case "Place your right index finger on the fingerprint reader":
					if (!resetTimer.running){
						opacityMask.invert = false
						displayText = "SCAN 󰈷 FINGERPRINT"
					}
					break
				case "Password: ":
					opacityMask.invert = false
					displayText = ""
					break

				default:
					console.warn(context.message)
					if (resetTimer.running && !context.responseRequired){
						displayText = "SYSTEM LOCKED"
					}
			}
		}
		function onFailure(){
			root.displayText = "ACCESS DENIED"
			resetTimer.restart()
		}
	}
	property int boxSize: width > 0 ? width / 12 : 0
	property int smallBoxSize: width > 0 && height > 0 ? (height - 7 * boxSize) / 2 : 0
	component CrossSquare: Rectangle{
		required property color crossColor
		color: Theme.bgBase
		width: boxSize
		height: boxSize
		Rectangle{
			anchors{
				top: parent.top
				bottom: parent.bottom
				horizontalCenter: parent.horizontalCenter
				margins: boxSize/4
			}
			color: crossColor
			width: 2
		}
		Rectangle{
			anchors{
				left: parent.left
				right: parent.right
				verticalCenter: parent.verticalCenter
				margins: boxSize/4
			}
			height: 2
			color: crossColor
		}
	}
	GridLayout{
		anchors{
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: (root.height - 7*root.boxSize)/2 - root.boxSize
		}
		columns: 12
		columnSpacing: 0
		rowSpacing: 0
		Repeater{
			model: 14*9
			delegate: CrossSquare{
				required property int index
				crossColor: Theme.textMuted
				color: Theme.bgBase
			}
		}
	}
	Rectangle{
		id: lockCenter
		anchors{
			top: parent.top
			topMargin: (root.boxSize * 3) + (root.height - 7*root.boxSize)/2
			horizontalCenter: parent.horizontalCenter
		}
		width: root.boxSize * 6
		height: root.boxSize
		color: Theme.accentRed
		Rectangle{
			id: mask
			visible: false
			color: Theme.textPrimary
			anchors.centerIn: parent
			width: 400
			height: 75
		}
		Text{
			anchors{
				top: parent.top
				left: parent.left
				right: parent.right
				topMargin: 5
			}
			horizontalAlignment: Text.AlignHCenter
			text: "ENTER PASSWORD"
			font.family: Theme.fontFancy
			font.pixelSize: 20
			visible: context.responseRequired && !resetTimer.running && displayText !== "VERIFYING"
		}
		TextField {
			id: password
			anchors{
				fill: parent
				leftMargin: root.boxSize + 20
				rightMargin: root.boxSize + 20
				topMargin: 20
				bottomMargin: 20
			}
			
			echoMode: TextInput.Password

			visible: context.responseRequired && !resetTimer.running
			font.pixelSize: 50
			horizontalAlignment: Text.AlignHCenter
			passwordCharacter: "*"
			background: Rectangle{
				color: "transparent"
			}
			onTextEdited: {
				countdown.restart()
				suspendTimer.restart()
			}
			onVisibleChanged: if(visible) { forceActiveFocus() }
			onAccepted: {
				context.submit(text)
				clear()
				root.displayText = "VERIFYING"
				opacityMask.invert = true
			}
		}
		Text{
			id: centerText
			visible: false
			anchors.fill: mask
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter 
			text: root.displayText
			font.family: Theme.fontFancy
			font.styleName: "Light"
			 width: mask.width
        	height: mask.height
			fontSizeMode: Text.Fit
			font.pixelSize: 45
			minimumPixelSize: 20
		}
		SequentialAnimation {
			id: flashAnim
			loops: 1
			running: true
			PropertyAction {
				target: opacityMask
				property: "invert"
				value: true
			}
			PauseAnimation { duration: 500 }

			PropertyAction {
				target: opacityMask
				property: "invert"
				value: false
			}
			PauseAnimation { duration: 500 }
		}
		OpacityMask{
			id: opacityMask
			anchors.fill: mask
			maskSource: centerText
			source: mask
			invert: false
		}					
		Repeater{
			model: [true, false]
			delegate: CrossSquare{
				required property var modelData
				anchors{
					top: parent.top
					bottom: parent.bottom
					right: modelData ? parent.right : undefined
					left: !modelData ? parent.left : undefined
				}
				crossColor: Theme.textPrimary
				color: Theme.accentRed
			}
		}	
		Repeater{
			model: [true, false]
			delegate: RowLayout{
				spacing: 0
				anchors{
					right: modelData ? parent.left : undefined
					left: !modelData ? parent.right : undefined
					verticalCenter: parent.verticalCenter
				}
				layoutDirection: modelData ? Qt.RightToLeft : Qt.LeftToRight
				Repeater{
					model: 4
					delegate: Rectangle{
						width: root.boxSize
						height: root.boxSize
						color: Theme.accentRed
						opacity: (1 - ((index+1) * 0.2))
						Behavior on opacity{
							SequentialAnimation{
								PauseAnimation{ duration: index * 50 }
								NumberAnimation{ duration: 1 }
							}
						}
					}
				}
			}
		}
		Text{
			anchors{
				bottom: parent.bottom
				left: parent.left
				right: parent.right
			}
			horizontalAlignment: Text.AlignHCenter
			font.family: Theme.fontFancy
			text: "System Suspending in " + root.timer + " Seconds"
		}
	}
}