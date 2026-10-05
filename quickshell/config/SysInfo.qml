pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {

    property bool inhibiting: false

    property int lastTotalTime: 1
    property int lastIdleTime: 1
    property string tempPath: ""
    property int maxRam: 1

    property int usage: 1
    property int temp: 1
    property int ram: 1
    IpcHandler {
        target: "idle"
        function toggle() {
            inhibiting = !inhibiting;
        }
    }
    Process {
        id: tempPathFinder
        command: ["sh", "-c", `find /sys/class/hwmon -maxdepth 1 -type l | while read d; do
    			name=$(cat "$d/name" 2>/dev/null)
   				case "$name" in
        			coretemp|k10temp) echo "$d"; exit 0 ;;
    			esac
			done
			# fallback to acpitz if nothing else found
			find /sys/class/hwmon -maxdepth 1 -type l | while read d; do
				[ "$(cat "$d/name" 2>/dev/null)" = "acpitz*" ] && echo "$d" && exit 0
			done`]
        running: true

        stdout: StdioCollector {
            onStreamFinished: tempPath = this.text.trim() + "/temp1_input"
        }
    }
    FileView {
        id: tempFile
        path: tempPath
        onTextChanged: {
            temp = parseInt(text()) / 1000;
        }
    }
    FileView {
        id: cpuUsageFile
        path: Qt.resolvedUrl("/proc/stat")
        onTextChanged: calcCurrentCPUVals()
    }

    FileView {
        id: ramFile
        property bool initialized: false
        path: Qt.resolvedUrl("/proc/meminfo")
        onTextChanged: calcRamUsage()
        onLoaded: {
            if (initialized)
                return;
            initialized = true;
            maxRam = text().split("\n")[0].split(/\s+/)[1];
        }
    }
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            cpuUsageFile.reload();
            tempFile.reload();
            ramFile.reload();
        }
    }
    function calcRamUsage() {
        if (!ramFile.initialized)
            return;
        let ramAvailable = ramFile.text().split("\n")[2].split(/\s+/)[1];
        ram = Math.round((1 - ramAvailable / maxRam) * 100);
    }
    function calcCurrentCPUVals() {
        let vals = cpuUsageFile.text().split("\n")[0].split(" ");
        let currentTotalTime = 0;
        let currentIdleTime = parseInt(vals[5]) + parseInt(vals[6]);
        for (let i = 2; i < vals.length; i++) {
            if (!isNaN(vals[i])) {
                currentTotalTime += parseInt(vals[i]);
            }
        }

        let delta_total = currentTotalTime - lastTotalTime;
        let delta_idle = currentIdleTime - lastIdleTime;
        usage = Math.round((delta_total - delta_idle) / delta_total * 100);
        lastIdleTime = currentIdleTime;
        lastTotalTime = currentTotalTime;
    }
}
