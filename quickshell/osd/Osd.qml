import QtQuick
import QtQuick.Layouts
import QtQuick.Studio.Components
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import Quickshell.Io
import "../config/themes"
Scope {
	id: root
	property var theme: DefaultTheme{}
	FontLoader {
		id: khinterference
		source: "../config/fonts/KHInterferenceTRIAL-Bold.woff2"
	}
	property bool volumeMode : true
	property bool shouldShowOsd: false
	property int colNums: 80
	property int rowNums: 5
	property int totalBoxes: colNums * rowNums
	property bool muted: Pipewire.defaultAudioSink?.audio.muted ?? false
	property real volume: Pipewire.defaultAudioSink?.audio.volume ?? 0
	property real brightness: 0.0
	property int maxBrightness: 1
	property string labelText: (volumeMode ? "VOLUME:" : "BRIGHTNESS: ") + (volumeMode && muted ? "MUTED" : String(Math.round((volumeMode ? volume : brightness)*100)).padStart(3, "0")+ "%") 
	
	property color strokeColor: theme.textPrimary
	property color fillColor: volumeMode ? (muted ? theme.textMuted : theme.accentPurple) : theme.accentGreen
	
	property real percent: volumeMode ? volume : brightness
	property int revealInd: percent * totalBoxes
	// Bind the pipewire node so its volume will be tracked
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}
	IpcHandler {
		target: "osd"

		function volume() {
			volumeMode = true
			root.shouldShowOsd = true
			hideTimer.restart()
		}
		function brightness(){
			volumeMode = false
			root.shouldShowOsd = true
			brightnessReadProc.running = true
			hideTimer.restart()
		}
	}

	Timer {
		id: hideTimer
		interval: 1500
		onTriggered: {
			root.shouldShowOsd = false
		}
	}

	
	Process {
		id: brightnessReadProc
		command: ["brightnessctl", "get"]
		running: false
		stdout: StdioCollector {
			onStreamFinished: {
				const val = parseInt(text.trim());
				if (!isNaN(val) && root.maxBrightness > 0) {
					root.brightness = val / root.maxBrightness
				}
			}
		}
	}
	Process {
		id: brightnessMaxProc
		command: ["brightnessctl", "max"]
		running: false
		stdout: StdioCollector {
		onStreamFinished: {
			const val = parseInt(text.trim());
				if (!isNaN(val)) {
					root.maxBrightness = val
				}
			}
		}
	}
	
	property var boxes: []

	function initVals() {
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
		brightnessMaxProc.running = true
	}

	LazyLoader {
		active: root.shouldShowOsd
		PanelWindow {
			property int boxSize: screen.width / colNums


			anchors.top: true
			margins.top: 0
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
					font.family: khinterference.name
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
					font.family: khinterference.name
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