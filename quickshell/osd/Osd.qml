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
	
	property color strokeColor: volumeMode ? (muted ? theme.textMuted : theme.accentPurple) : theme.accentGreen
	property color fillColor: theme.textPrimary
	
	// Bind the pipewire node so its volume will be tracked
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}
	IpcHandler {
		target: "osd"

		function volume() {
			volumeMode = true
			root.shouldShowOsd = true
			reslice()
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
				root.reslice()
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
	
	property var revealed: []
	property var unrevealed: []
	property var boxes: null

	function initVals() {
		boxes = []
		for (let x = 0; x < colNums; x++) {
			for (let y = 0; y < rowNums; y++) {
				let leftBias = (colNums - x) / colNums
				let random = Math.random()

				boxes.push({
					id: y * colNums + x,
					score: leftBias * 0.80 + random * 0.20
				})
			}
		}

		boxes.sort((a, b) => b.score - a.score)
	}
	function reslice(){
		let percent = volumeMode ? volume : brightness
		if (!boxes)
        	return
		revealed = boxes
			.slice(0, percent * totalBoxes)
			.map(b => b.id)
		unrevealed = boxes.slice(percent * totalBoxes).map(b => b.id)
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
					strokeColor: root.strokeColor
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

								property bool isRevealed: revealed.includes(modelData)
								color: root.fillColor
								opacity: isRevealed ? 1 : 0

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
					strokeStyle: None
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