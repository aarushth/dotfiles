import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../config"

PanelWindow {
	id: introWindow
	
	signal locked()
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
		NumberAnimation{ target: center; property: "opacity"; from: 0; to: 1; easing.type: Easing.InBounce; easing.amplitude: 2.0; duration: 300; }
		PropertyAction{ target:base; property: "op"; value: 0.7}
		ParallelAnimation{
			PropertyAction{ target: cornersContainer; property: "revealCorners"; value: true}
			NumberAnimation{
				target: center
				property: "width"
				from: 145
				to: 950
				duration: 400
				easing.type: Easing.InQuad
			}
			NumberAnimation{
				target: cpus
				property: "width"
				from: 0
				to: cpuLayout.implicitWidth
				duration: 400
				easing.type: Easing.InQuad
			}
		}
		PropertyAction{ target:centerLabel; property: "visible"; value: true}
		PropertyAction{ target: base; property: "revealEars"; value: true;}
		ParallelAnimation{
			NumberAnimation{ target: base; property: "op"; to: 1; duration: 1000}
			SequentialAnimation{
				NumberAnimation{ target: centerWrapper; property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.InBounce; easing.amplitude: 2.0; duration: 300; }
				PropertyAction{ target: cpus; property: "revealCpus"; value: true}
			}
			PropertyAction{ target: center; property: "revealSquiggle"; value: true}	
		}
		PauseAnimation{ duration: 500 }
		PropertyAction{ target: base; property: "revealLockReady"; value: true}
		PauseAnimation{ duration: 500 }
		PropertyAction{ target: base; property: "locking"; value: true}
		PauseAnimation{ duration: 1300 }
		PropertyAction{ target: base; property: "locked"; value: true}
		PauseAnimation{ duration: 200 }
		ScriptAction{ script: introWindow.locked() }
	}
	Rectangle{
		id: base
		anchors.fill: parent
		property real op: 0
		color: Qt.rgba(0,0,0,op)
		property bool revealEars: false
		property bool revealLockReady: false
		property bool locking: false
		property bool locked: false
		Repeater {
			id: cornersContainer
			model: introWindow.corners
			property bool revealCorners: false
			
			delegate: Item{
				width: 50
				height: 50
				opacity: cornersContainer.revealCorners ? 1 : 0
				anchors{
					top: modelData.top ? parent.top : undefined
					bottom: !modelData.top ? parent.bottom : undefined
					left: modelData.left ? parent.left : undefined
					right: !modelData.left ? parent.right : undefined
				}
				Behavior on opacity{
					NumberAnimation{ easing.type: Easing.InBounce; easing.amplitude: 2.0; duration: 300; }
				}
				Rectangle{
					id: vert
					width: 1
					color: Theme.accentRed
					anchors{
						top: parent.top
						bottom: parent.bottom
						horizontalCenter: parent.horizontalCenter
						
					}
				}
				Rectangle{
					id: hori
					height: 1
					color: Theme.accentRed
					anchors{
						left: parent.left
						right: parent.right
						verticalCenter: parent.verticalCenter
					}
				}
				Rectangle{
					anchors.centerIn: parent
					width: 5
					height: 5
					radius: 2
					color: Theme.accentRed
				}
				Image {
					id: butterfly
					visible: modelData.top && modelData.left
					anchors{
						left: vert.right
						top: hori.bottom
						margins: 10
					}
					opacity: base.revealEars ? 1 : 0
					Behavior on opacity{
						SequentialAnimation{
							NumberAnimation{ easing.type: Easing.InBounce; easing.amplitude: 2.0; duration: 300; }
							NumberAnimation{ target:logs; property: "maximumLineCount"; from: 1; to: 25; duration: 1500; easing.type: Easing.OutQuad }
						}
					}
					sourceSize: Qt.size(60, 60)
					width: 60
					height: 60
					source: "butterfly.svg"
				}
				Text{
					id: logs
					visible: modelData.top && modelData.left
					anchors{
						top: butterfly.bottom
						left: butterfly.left
						margins: 5 
					}
					color: Theme.accentRed
					font.family: Theme.fontNormal
					font.pixelSize: 7
					maximumLineCount: 1
					text: "CORES [SECURING…]\nSYS OVERRIDE\n" + Quickshell.env("USER") + " SYS_DISRUPT | CONTROL [REVOKE]\n\n  DISPLAY LOCKING\n  DISPLAY LOCKING\n  DISPLAY LOCKING\n  DISPLAY LOCKING\n\nNO CONTROL\n  DISPLAY LOCKING\n  DISPLAY LOCKING\n  DISPLAY LOCKING\n  DISPLAY LOCKING\n\nNO CONTROL\n  DISPLAY LOCKING\n  DISPLAY LOCKING\n  DISPLAY LOCKING\n  DISPLAY LOCKING\n\nSYS CONTROL [LOST]\nSIGNAL INTERRUPTION\n[YES]\nRESULTS PRNT"
				}
				Rectangle{
					anchors{
						top: modelData.top ? hori.bottom : undefined
						bottom: !modelData.top ? hori.top : undefined
						left: modelData.left ? vert.right : undefined
						right: !modelData.left ? vert.left : undefined
						margins: 10
					}
					height: 60
					width: 325
					color: Theme.accentRed
					opacity: base.revealLockReady ? 1 : 0
					Behavior on opacity{
						NumberAnimation{ easing.type: Easing.InBounce; easing.amplitude: 2.0; duration: 300; }
					}
					Text{
						text: "SYSTEM"
						anchors{
							left: modelData.left ? parent.left : undefined
							right: !modelData.left ? parent.right : undefined
							top: parent.top
							margins: 5
						}
						font.family: Theme.fontFancy
						color: Theme.textPrimary
						font.pixelSize: 25
						font.styleName: "Light"
					}
					Text{
						text: "LOCKING…"
						anchors{
							left: modelData.left ? parent.left : undefined
							right: !modelData.left ? parent.right : undefined
							bottom: parent.bottom
							margins: 5
						}
						font.family: Theme.fontFancy
						color: Theme.textPrimary
						font.pixelSize: 25
						font.styleName: "Light"
					}
					Rectangle{
						anchors{
							top: parent.top
							bottom: parent.bottom
							left: !modelData.left ? parent.left : undefined
							right: modelData.left ? parent.right : undefined
							margins: 5
						}
						width: 50
						border.width: 2
						border.color: "black"
						color: Theme.accentRed
						GridLayout{
							anchors.centerIn: parent
							columns: 7
							columnSpacing: 0
							rowSpacing: 0
							Repeater{
								model: 7 * 7
								delegate: Rectangle{
									width: 6
									height: 6
									color: Math.random() > 0.5 ? Theme.accentRed : Theme.textPrimary
								}
							}
						}
					}
					Rectangle{
						id: secondVert
						width: 1
						anchors{
							top: parent.top
							bottom: parent.bottom
							left: modelData.left ? parent.right : undefined
							right: !modelData.left ? parent.left : undefined
							leftMargin: 20
							rightMargin: 20
						}
						color: Theme.accentRed
					}
					Rectangle{
						height: 1
						width: 100
						anchors{
							verticalCenter: secondVert.verticalCenter
							left: modelData.left ? secondVert.right : undefined
							right: !modelData.left ? secondVert.left : undefined
						}
						color: Theme.accentRed
					}
				}
			}
		}
		Rectangle{
			id: center
			anchors.centerIn: parent
			color: Theme.accentRed
			width: 145
			height: 145
			radius: 2
			opacity: 0
			property bool revealSquiggle: false

			Repeater {
				model: introWindow.corners

				delegate: Rectangle {
					required property var modelData

					width: 12
					height: 12
					color: Theme.textPrimary
					anchors{
						top: modelData.top ? parent.top : undefined
						bottom: !modelData.top ? parent.bottom : undefined
						left: modelData.left ? parent.left : undefined
						right: !modelData.left ? parent.right : undefined
					}
					Rectangle {
						anchors.centerIn: parent
						width: 5
						height: 5
						radius: width / 2
						color: Theme.accentRed
					}
					Text {
						text: "Locking"
						font.pixelSize: 7
						font.family: Theme.fontNormal

						anchors.top: modelData.top ? parent.top : undefined
						anchors.bottom: !modelData.top ? parent.bottom : undefined

						anchors.left: modelData.left ? parent.right : undefined
						anchors.right: !modelData.left ? parent.left : undefined
						
						padding: 2
					}
					Rectangle{
						color: Theme.accentRed
						width: 1
						height: 12
						anchors{
							top: !modelData.top ? parent.bottom : undefined
							bottom: modelData.top ? parent.top : undefined
							left: modelData.left ? parent.left : undefined
							right: !modelData.left ? parent.right : undefined
							topMargin: 5
							bottomMargin: 5
						}
					}
					Rectangle{
						color: Theme.accentRed
						width: 12
						height: 1
						anchors{
							top: modelData.top ? parent.top : undefined
							bottom: !modelData.top ? parent.bottom : undefined
							left: !modelData.left ? parent.right : undefined
							right: modelData.left ? parent.left : undefined
							leftMargin: 5
							rightMargin: 5
						}
					}
					Item{
						id: ears
						anchors{
							top: !modelData.top ? parent.bottom : undefined
							bottom: modelData.top ? parent.top : undefined
							left: modelData.left ? parent.left : undefined
							right: !modelData.left ? parent.right : undefined
							topMargin: -1
							bottomMargin: -1
							leftMargin: modelData.left ? -1 : 0
							rightMargin: !modelData.left? -1 : 0
						}
						width: 50
						height: base.revealEars ? 50 : 0
						Behavior on height{
							NumberAnimation{ duration: 200 }
						}
						clip: true
						Rectangle{
							anchors.fill: parent
							color: Theme.accentRed
							Rectangle{
								id: vert
								width: 1
								color: Theme.textPrimary
								anchors{
									top: parent.top
									bottom: parent.bottom
									horizontalCenter: parent.horizontalCenter
									
								}
							}
							Rectangle{
								id: hori
								height: 1
								color: Theme.textPrimary
								anchors{
									left: parent.left
									right: parent.right
									verticalCenter: parent.verticalCenter
								}
							}
							Rectangle{
								anchors.centerIn: parent
								width: 5
								height: 5
								radius: 2
								color: Theme.textPrimary
							}
						}
					}
					Text{
						visible: modelData.top && modelData.left && base.revealEars
						text: "󰀅"
						color: Theme.accentRed
						font.family: Theme.fontTitle
						font.pixelSize: 25
						font.styleName: "Black"
						font.capitalization: Font.AllUppercase
						anchors{
							right: ears.left
							verticalCenter: ears.verticalCenter
							rightMargin: 5
							topMargin: base.revealEars ? 0 : -20
							Behavior on topMargin{
								NumberAnimation{ duration: 200}
							}
						}
					}
					Image {
						id: squiggle
						visible: !modelData.top && modelData.left
						anchors{
							left: ears.right
							verticalCenter: ears.verticalCenter
							margins: 10
						}
						opacity: center.revealSquiggle ? 0.9 : 0
						Behavior on opacity{
							NumberAnimation{ easing.type: Easing.InBounce; easing.amplitude: 2.0; duration: 300; }
						}
						sourceSize: Qt.size(60, 60)
						width: 40
						height: 40
						source: "squiggle.svg"
					}
					Text{
						visible: !modelData.top && modelData.left && center.revealSquiggle
						anchors{
							left: squiggle.right
							top: squiggle.verticalCenter
							topMargin: -10
							leftMargin: 10
						}
						text: "CORES [SECURING…]\nSYS OVERRIDE - SIGNAL BARRIER ENABLED"
						color: Theme.accentRed
						font.family: Theme.fontNormal
						font.pixelSize: 8
						maximumLineCount: center.revealSquiggle ? 2 : 1
						Behavior on maximumLineCount{
							NumberAnimation{ easing.type: Easing.InExpo; easing.amplitude: 2.0; duration: 1000; }
						}
					}
					Text{
						visible: !modelData.top && modelData.left && center.revealSquiggle
						anchors{
							top: ears.bottom
							left: ears.left
							topMargin: 20
						}
						text: "CORES [SECURING…]\nSYS OVERRIDE\nNETWORK ACCESS[DISABLING…]\nNO-2"
						color: Theme.accentRed
						font.family: Theme.fontNormal
						font.pixelSize: 8
						maximumLineCount: center.revealSquiggle ? 4 : 1
						Behavior on maximumLineCount{
							NumberAnimation{ easing.type: Easing.InExpo; easing.amplitude: 2.0; duration: 1000; }
						}
					}
					Text{
						visible: modelData.top && modelData.left && base.revealEars
						text: Quickshell.env("USER")
						color: Theme.accentRed
						font.family: Theme.fontTitle
						font.pixelSize: 20
						font.styleName: "Black"
						font.capitalization: Font.AllUppercase
						anchors{
							left: ears.right
							verticalCenter: ears.verticalCenter
							leftMargin: 15
							topMargin: base.revealEars ? 0 : -20
							Behavior on topMargin{
								NumberAnimation{ duration: 200}
							}
						}
					}
				}
			}
			
			Item{
				id: centerWrapper
				anchors.fill: parent
				opacity: 1
				Text{
					id: lockIcon
					anchors{
						top: parent.top
						bottom: parent.bottom
						left: parent.left
					}
					width: 145
					color: Theme.textPrimary
					text: "󰍁"
					font.pixelSize: 100
					verticalAlignment: Text.AlignVCenter
					horizontalAlignment: Text.AlignHCenter
					font.family: "Symbols Nerd Font Mono"
				}
				Text{
					id: centerLabel
					text: "SYSTEM\nLOCKING!"
					visible: false
					anchors{
						verticalCenter: parent.verticalCenter
						left: lockIcon.right
					}
					font.family: Theme.fontFancy
					font.styleName: "Light"
					font.pixelSize: 50
				}
				Item{
					id: cpus
					clip: true
					width: 0
					anchors{
						top: parent.top
						bottom: parent.bottom
						right: parent.right
						rightMargin: 20
					}
					property bool revealCpus: false
					GridLayout{
						id: cpuLayout
						columns: 8
						anchors{
							verticalCenter: parent.verticalCenter
							left: parent.left
						}
						Repeater{
							model: 16
							delegate: Item{
								width: 50
								height: 50
								Item{
									id: cross
									anchors.fill: parent
									visible: false
									Rectangle{
										id: vert
										width: 2
										color: Theme.textPrimary
										anchors{
											top: parent.top
											bottom: parent.bottom
											horizontalCenter: parent.horizontalCenter
											
										}
									}
									Rectangle{
										id: hori
										height: 2
										color: Theme.textPrimary
										anchors{
											left: parent.left
											right: parent.right
											verticalCenter: parent.verticalCenter
										}
									}
									Text{
										anchors{
											left: vert.right
											bottom: hori.top
										}
										padding: 2
										text: "CPU" + index
										font.family: Theme.fontNormal
										font.pixelSize: 7
									}
								}
								Item{
									id: base
									visible: false
									anchors.fill: parent
									Rectangle{
										anchors{
											top: parent.top
											left: parent.left
											right: parent.right
										}
										height: cpus.revealCpus ? parent.height: 0
										color: Theme.textPrimary
										Behavior on height{
											SequentialAnimation{
												PauseAnimation{ duration: index * 50 }
												NumberAnimation{ 
													duration: 1000
													easing.type: Easing.OutExpo
												}

											}
										}
									}
								}
								OpacityMask{
									anchors.fill: parent
									source: base
									maskSource: cross 
									invert: true
								}
								OpacityMask{
									anchors.fill: parent
									source: cross 
									maskSource: base
									invert: true
								}
							}
						}
					}
				}
			}
		}
		GridLayout{
			anchors{
				horizontalCenter: parent.horizontalCenter
				top: parent.top
				topMargin: (screen.height - 7*introWindow.boxSize)/2 - introWindow.boxSize
			}
			columns: 14
			columnSpacing: 0
			rowSpacing: 0
			Repeater{
				model: 14*9
				delegate: CrossSquare{
					required property int index
					opacity: base.locking ? 1 : 0
					Behavior on opacity{
						SequentialAnimation {
							PauseAnimation { duration: Math.min(index, 14*9 - index) * 20 }
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
				topMargin: (introWindow.boxSize * 3) + (screen.height - 7*introWindow.boxSize)/2
				horizontalCenter: parent.horizontalCenter
			}
			opacity: base.revealLockReady ? 1 : 0
			Behavior on opacity{
				NumberAnimation{ easing.type: Easing.InBounce; easing.amplitude: 2.0; duration: 300; }
			}
			width: introWindow.boxSize * 6
			height: introWindow.boxSize
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
				id: centerText
				visible: false
				anchors.fill: mask
				verticalAlignment: Text.AlignVCenter
				horizontalAlignment: Text.AlignHCenter 
				text: "SYSTEM LOCKED"
				font.family: Theme.fontFancy
				font.styleName: "Light"
				font.pixelSize: 45
			}
			SequentialAnimation {
				running: base.locking
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
							width: introWindow.boxSize
							height: introWindow.boxSize
							color: Theme.accentRed
							opacity: base.locked ? (1 - ((index+1) * 0.2)) : 0
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
		}
	}
}