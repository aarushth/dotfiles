import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../config"

PanelWindow {
	id: exitWindow
	property int boxSize: screen.width/12
	property int smallBoxSize: (screen.height - (7 * boxSize))/2
	property var corners: [
				{ top: true,  left: true  },
				{ top: true,  left: false },
				{ top: false, left: true  },
				{ top: false, left: false }
			]
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
	exclusionMode: ExclusionMode.Ignore
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive	
	WlrLayershell.namespace: "quickshell-lockscreen"
	anchors{
		top: true
		bottom: true
		left: true
		right: true
	}
	color: "transparent"
	SequentialAnimation{
		running: true
		PauseAnimation{ duration: 800 }
		PropertyAction{ target: centerText; property: "text"; value: "SYSTEM UNLOCK" }
		PropertyAction{ target: base; property: "unlocked"; value: true}
		PauseAnimation{ duration: 200 }
		PropertyAction{ target: base; property: "unlocking"; value: true}
		PauseAnimation{ duration: 1100 }
		PropertyAction{ target: base; property: "hideLockReady"; value: true }
		PauseAnimation{ duration: 200 }
		ScriptAction{ script: root.shouldShowUnlockscreen = false}
	}
	Rectangle{
		id: base
		anchors.fill: parent
		property real op: 0
		color: Qt.rgba(0,0,0,op)
		property bool hideLockReady: false
		property bool unlocking: false
		property bool unlocked: false
		GridLayout{
			anchors{
				horizontalCenter: parent.horizontalCenter
				top: parent.top
				topMargin: (screen.height - 7*exitWindow.boxSize)/2 - exitWindow.boxSize
			}
			columns: 14
			columnSpacing: 0
			rowSpacing: 0
			Repeater{
				model: 14*9
				delegate: CrossSquare{
					required property int index
					opacity: base.unlocking ? 0 : 1
					Behavior on opacity{
						SequentialAnimation {
							PauseAnimation { duration: ((14*9)/2 - Math.min(index, 14*9 - index) )* 20 }
							NumberAnimation { duration: 1 }
						}
					}
					crossColor: Theme.textMuted
					color: Theme.bgBase
				}
			}
		}
		Rectangle{
			id: lockCenter
			anchors{
				top: parent.top
				topMargin: (exitWindow.boxSize * 3) + (screen.height - 7*exitWindow.boxSize)/2
				horizontalCenter: parent.horizontalCenter
			}
			opacity: base.hideLockReady ? 0 : 1
			Behavior on opacity{
				NumberAnimation{ easing.type: Easing.InBounce; easing.amplitude: 2.0; duration: 300; }
			}
			width: exitWindow.boxSize * 6
			height: exitWindow.boxSize
			color: Theme.accentGreen
			Rectangle{
				id: mask
				visible: false
				color: Theme.textPrimary
				anchors.centerIn: parent
				width: 400
				height: 75
			}
			Text{
				id: centerText
				visible: false
				anchors.fill: mask
				verticalAlignment: Text.AlignVCenter
				horizontalAlignment: Text.AlignHCenter 
				text: "ACCESS GRANTED"
				font.family: Theme.fontFancy
				font.styleName: "Light"
				font.pixelSize: 45
			}
			SequentialAnimation {
				running: true
				loops: Animation.Infinite

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
					color: Theme.accentGreen
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
							width: exitWindow.boxSize
							height: exitWindow.boxSize
							color: Theme.accentGreen
							opacity: base.unlocked ? 0 : (1 - ((index+1) * 0.2)) 
							Behavior on opacity{
								SequentialAnimation{
									PauseAnimation{ duration: (4-index) * 50 }
									NumberAnimation{ duration: 1 }
								}
							}
						}
					}
				}
			}
		}
	}
}