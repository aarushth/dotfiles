import QtQuick
import QtQuick.Layouts
import QtQuick.Studio.Components
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import Quickshell.Io

Scope {
	id: root
	FontLoader {
		id: khinterference
		source: "fonts/KHInterferenceTRIAL-Bold.woff2"
	}
	property bool volumeMode : true
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
			brightnessReadProc.running = true
			root.shouldShowOsd = true
			hideTimer.restart()
		}
	}

	property bool shouldShowOsd: false

	Timer {
		id: hideTimer
		interval: 1500
		onTriggered: root.shouldShowOsd = false
	}

	property int colNums: 80
	property int rowNums: 5
	property int totalBoxes: colNums * rowNums
	property bool muted: Pipewire.defaultAudioSink?.audio.muted ?? false
	property real volume: Pipewire.defaultAudioSink?.audio.volume ?? 0
	property real brightness: 0.0
	property int maxBrightness: 1
	property string labelText: (volumeMode ? "VOLUME:" : "BRIGHTNESS: ") + (muted ? "MUTED" : String(Math.round((volumeMode ? volume : brightness)*100)).padStart(3, "0")) + "%"

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

	// The OSD window will be created and destroyed based on shouldShowOsd.
	// PanelWindow.visible could be set instead of using a loader, but using
	// a loader will reduce the memory overhead when the window isn't open.
	
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

			// An empty click mask prevents the window from blocking mouse events.
			// mask: Region {}

			Item {
				anchors.fill: parent
				TextItem {
					id: textBottom
					anchors.fill: parent
					text: labelText
					font.family: khinterference.name
					font.pointSize: 70					
					horizontalAlignment: Text.AlignHCenter
					fillColor: "transparent"
					strokeColor: volumeMode ? (muted ? "darkGrey" : "green") : "purple"
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
								color: volumeMode ? (muted ? "grey" : "purple") : "green"
								opacity: isRevealed ? 1 : 0

								Behavior on opacity {
									NumberAnimation {
										duration: 800
										easing.type: Easing.InOutQuad
									}
								}
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
					fillColor: volumeMode ? (muted ? "darkGrey" : "green") : "purple"
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