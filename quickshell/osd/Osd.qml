import QtQuick
import QtQuick.Layouts
import QtQuick.Studio.Components
import Quickshell.Wayland
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import "../config"
Scope {
	id: root
	property bool volumeMode : true
	property bool shouldShowOsd: false
	property int colNums: 80
	property int rowNums: 5
	property int totalBoxes: colNums * rowNums
	property bool muted: OsdData.muted
	property real volume: OsdData.volume
	property real brightness: OsdData.brightness
	property string labelText: (volumeMode ? "VOLUME:" : "BRIGHTNESS: ") + (volumeMode && muted ? "MUTED" : String(Math.round((volumeMode ? volume : brightness)*100)).padStart(3, "0")+ "%") 
	
	property color strokeColor: Theme.textPrimary
	property color fillColor: volumeMode ? (muted ? Theme.textMuted : Theme.accentPurple) : Theme.accentGreen
	
	property real percent: volumeMode ? volume : brightness
	property int revealInd: percent * totalBoxes
	property bool volumeCalled: OsdData.volumeCalled
	property bool brightnessCalled: OsdData.brightnessCalled
	property bool initialized: false
	Behavior on volume{
		NumberAnimation{ duration: 200 }
	}
	
	Behavior on brightness{
		NumberAnimation{ duration: 200 }
	}
	onVolumeCalledChanged: if (initialized) showOsd(true)
	onBrightnessCalledChanged: if (initialized) showOsd(false)
	function showOsd(mode){
		volumeMode = mode
		shouldShowOsd = true
		hideTimer.restart()
	}
	Timer {
		id: hideTimer
		interval: 1500
		onTriggered: {
			root.shouldShowOsd = false
		}
	}
	property var boxes: []
	function biasFunc(index){
		return (colNums - index % colNums) / colNums
	}

	Component.onCompleted: {

		boxes = Boxes.getBoxes(totalBoxes, biasFunc, "osd")
		initialized = true
	}

	LazyLoader {
		active: root.shouldShowOsd
		Variants{
			model: Quickshell.screens
			delegate: PanelWindow {
				id: window
				property var modelData
				property int boxSize: screen.width / colNums
				screen: modelData
				WlrLayershell.layer: WlrLayer.Overlay
				WlrLayershell.namespace: "quickshell-osd"
				anchors.top: true
				exclusiveZone: 0
				implicitWidth: screen.width
				implicitHeight: boxSize * rowNums
				color: "transparent"
				Item {
					id: fadeRoot
					anchors.fill: parent
					visible: true

					TextItem {
						id: textBottom
						anchors.fill: parent
						text: labelText
						font.family: Theme.fontFancy
						font.pointSize: window.implicitHeight * 0.9			
						horizontalAlignment: Text.AlignHCenter
						fillColor: "transparent"
						strokeColor: root.fillColor
						strokeWidth: 2
						font.bold: true
					}
					Item {
						id: squares
						anchors.fill: parent
						visible: true
						
						Grid {
							anchors.fill: parent
							columns: colNums
							rows: rowNums

							Repeater {
								model: totalBoxes

								delegate: Rectangle {
									width: boxSize
									height: boxSize
									property int idx: 100000
									Component.onCompleted: idx = root.boxes[index]
									color: root.fillColor
									opacity: (idx < root.revealInd) ? 1 : 0

								}
							}
						}
					}

					TextItem {
						id: textTop
						anchors.fill: parent
						text: labelText
						font.family: Theme.fontFancy
						horizontalAlignment: Text.AlignHCenter
						font.pointSize: window.implicitHeight * 0.9	
						font.bold: true
						fillColor: root.strokeColor
						strokeStyle: 0
						visible: false
					}

					OpacityMask {
						anchors.fill: parent
						source: textTop
						maskSource: squares
					}
				}
			}
		}
	}

}