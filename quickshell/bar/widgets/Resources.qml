import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../../config"

Item{
	id: root 
	required property int boxSize
	required property int rows
	required property int cols
	required property var boxes
	property int lastTotalTime: 1
	property int lastIdleTime: 1
	property string tempPath: ""
	property int maxRam: 1

	property int usage: 1
	property int temp: 1
	property int ram: 1
	
	property string usageString: Icons.cpuIcon + String(usage).padStart(3, 0) + "%" 
	property string tempString: Icons.getTempIcon(temp) + String(temp).padStart(3, 0) + "󰔄" 
	property string ramString: Icons.ramIcon + String(ram).padStart(3, 0) + "%"
	width: boxSize * cols
	Layout.preferredHeight: parent.height
	FileView {
		id: cpuUsageFile
		path: Qt.resolvedUrl("/proc/stat")
		onTextChanged: calcCurrentCPUVals()
	}
	Process {
		id: tempPathFinder
		running: true
		command: [
			"sh",
			"-c",
			"find /sys/class/hwmon -maxdepth 1 -type l | while read d; do if [ \"$(cat \"$d/name\" 2>/dev/null)\" = acpitz ]; then echo \"$d\"; break; fi; done"
		]
		stdout: StdioCollector {
			onStreamFinished: tempPath = this.text.trim()  + "/temp1_input"
		}
	}
	FileView {
		id: tempFile
		path: tempPath
		onTextChanged: {
			temp = parseInt(text())/1000
		}
	}
	FileView {
		id: ramFile
		property bool initialized: false
		path: Qt.resolvedUrl("/proc/meminfo")
		onTextChanged: calcRamUsage()
		onLoaded: {
			if (initialized)
				return
			initialized = true
			maxRam = text().split("\n")[0].split(/\s+/)[1]
		}
	}
	Timer {
        interval: 3000; running: true; repeat: true
        onTriggered: {
			cpuUsageFile.reload()
			tempFile.reload()
			ramFile.reload()
		}
    }
	function calcRamUsage(){
		if(!ramFile.initialized)
			return
		let ramAvailable = ramFile.text().split("\n")[2].split(/\s+/)[1]
		ram = Math.round((1 - ramAvailable/maxRam) * 100)
	}
	function calcCurrentCPUVals(){
		let vals = cpuUsageFile.text().split("\n")[0].split(" ")
		let currentTotalTime = 0
		let currentIdleTime = parseInt(vals[5]) + parseInt(vals[6])
		for(let i = 2; i < vals.length; i++){
			if(!isNaN(vals[i])){
				currentTotalTime += parseInt(vals[i])
			}
		}
		
		let delta_total = currentTotalTime - lastTotalTime
		let delta_idle  = currentIdleTime - lastIdleTime
		usage = Math.round((delta_total - delta_idle) / delta_total * 100)
		lastIdleTime = currentIdleTime
		lastTotalTime = currentTotalTime		
	}
	Grid{
		id: grid
		anchors.fill: parent
		columns: cols
		rows: rows
		property int revealInd: mouse.containsMouse ? boxes.length : 0
		Behavior on revealInd {
			NumberAnimation { duration: 300 }
		}
		Repeater {
			model: cols * rows
			delegate: Rectangle {
				required property int index
				width: boxSize
				height: boxSize
				property int idx: boxes[index]
				color: (idx < grid.revealInd) ? Theme.accentPurpleHover : Theme.accentPurple
			}
		}
	}
	ColumnLayout{
		spacing: 0
		anchors.fill: parent
		Repeater{
			model: [usageString, tempString, ramString]
			delegate: Item{
				width: boxSize * 5
				height: (boxSize * 4-10) / 3
				Text{
					id: icon
					text: modelData[0]
					width: boxSize * 2
					anchors{
						top: parent.top
						bottom: parent.bottom
						left: parent.left
					}
					verticalAlignment: Text.AlignVCenter
					horizontalAlignment: Text.AlignHCenter
					font.family: "Symbols Nerd Font Mono"
				}
				Text{
					text: modelData.slice(1)
					font.family: Theme.fontFancy
					anchors{
						left: icon.right
						right: parent.right
						top: parent.top
						bottom: parent.bottom
					}
					verticalAlignment: Text.AlignVCenter
				}
			}
		}
	}
	
	MouseArea{
		id: mouse
		anchors.fill: parent
		hoverEnabled: true
		onClicked: {
			console.warn(Hyprland.toplevels.values)
			for(const top of Hyprland.toplevels.values){
				if(top.wayland.appId == "btop"){
					Hyprland.dispatch("hl.dsp.focus({workspace = \"name:btop\"})")
					return
				}
			}
			Hyprland.dispatch("hl.dsp.exec_cmd(\"kitty --class btop -e btop\")")
		}
	}
}