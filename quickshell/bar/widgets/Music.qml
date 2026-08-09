import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick
import "../../config"
Item{
	id: root
	required property int boxSize
	Layout.preferredHeight: parent.height 
	property var cavaVals: new Array(25)
	
	Process{
		id: cavaProcess
		command: "cava" 
		running: true
		stdout: SplitParser{
			onRead:(data) => cavaVals = data.split(";").filter(Boolean);
		}
	}
	RowLayout{
		spacing: 0
		Repeater{
			model: cavaVals
			delegate: ColumnLayout{
				id: col
				required property int index
				required property var modelData
				
				spacing: 0
				layoutDirection: Qt.LeftToRight
				Repeater{
					model: 8
					delegate: Rectangle{
						required property int index 
						property int idx: index + col.index * 8
						width: root.boxSize/2
						height: root.boxSize/2
						color: (8-index) < col.modelData ? Theme.accentPurpleHover : Theme.accentPurple 
					}
				}
			}
		}
	}

}
