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
	https://github.com/qt-labs/qtquickdesigner-components
	property var boxes: []

	function initVals() {
		initialized = true
		var temp = []
        boxes = new Array(totalBoxes)
		for (let x = 0; x < colNums; x++) {
			for (let y = 0; y < rowNums; y++) {
				let leftBias = (colNums - x) / colNums
				let random = Math.random()

				temp.push({
					id: y * colNums + x,
					score: leftBias * 0.80 + random * 0.20
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

	LazyLoader {
		active: root.shouldShowOsd
		PanelWindow {
			property int boxSize: screen.width / colNums
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
					font.pointSize: 70					
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
					font.pointSize: 70
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