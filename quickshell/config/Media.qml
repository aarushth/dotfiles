pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Scope {
    id: root
    property var cavaVals: new Array(25)

    property var defaultAudioSink: Pipewire.defaultAudioSink

    onDefaultAudioSinkChanged: {
        cavaProcess.signal("SIGKILL");
    }
    property var cavaProcess: Process {
        id: cavaProcess
        command: ["cava", "-p", Quickshell.env("HOME") + "/.config/cava/bar"]
        running: true
        onRunningChanged: {
            if (!running)
                running = true;
        }
        stdout: SplitParser {
            onRead: data => root.cavaVals = data.split(";").filter(Boolean)
        }
    }
}
