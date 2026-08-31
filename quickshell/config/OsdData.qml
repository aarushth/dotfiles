pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io

Scope{
    id: root
     
    enum Mode {
        Volume,
        Brightness,
        Mic
    }
    signal show(mode : int)
	property bool muted: defaultAudioSink?.audio.muted ?? false
	property real volume: defaultAudioSink?.audio.volume ?? 0
    property bool micMuted: Pipewire.defaultAudioSource?.audio.muted ?? false
    property real brightness: 1.0
    property int maxBrightness: 1
    property var defaultAudioSink: Pipewire.defaultAudioSink
    property var sinkNodes: Pipewire.nodes.values.filter((node) => node.isSink && !node.isStream)
	PwObjectTracker {
        objects	: [ Pipewire.defaultAudioSink, Pipewire.defaultAudioSource, Pipewire.nodes, Pipewire.preferredAudioSink]
	}
	IpcHandler {
		target: "osd"

		function volume() {
            show(OsdData.Mode.Volume)
        }
		function brightness(){
			brightnessReadProc.running = true
            show(OsdData.Mode.Brightness)
        }
        function mic(){
            show(OsdData.Mode.Mic)
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
    function setPreferredSink(node) {
        console.warn("here")    
        Pipewire.preferredDefaultAudioSink = node
    }
}
