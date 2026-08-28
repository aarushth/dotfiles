pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope{
	id: root
	property var cavaVals: new Array(25)
	
	property var cavaProcess: Process{
		id: cavaProcess
		command: "cava" 
		running: true
		stdout: SplitParser{ onRead:(data) => root.cavaVals = data.split(";").filter(Boolean); }
	}
}