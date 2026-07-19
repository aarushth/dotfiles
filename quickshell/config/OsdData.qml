pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io

Scope{
	id: root
	property bool muted: Pipewire.defaultAudioSink?.audio.muted ?? false
	property real volume: Pipewire.defaultAudioSink?.audio.volume ?? 0
	property real brightness: 1.0
	property int maxBrightness: 1
	property bool volumeCalled: true
	property bool brightnessCalled: true
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}
	function showVolume(){
		volumeCalled = !volumeCalled
	}
	function showBrightness(){
		brightnessReadProc.running = true
		brightnessCalled = !brightnessCalled
	}
	IpcHandler {
		target: "osd"

		function volume() {
			showVolume()
		}
		function brightness(){
			showBrightness()
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
		running: true
		stdout: StdioCollector {
		onStreamFinished: {
			const val = parseInt(text.trim());
				if (!isNaN(val)) {
					root.maxBrightness = val
					brightnessReadProc.running = true
				}
			}
		}
	}
}