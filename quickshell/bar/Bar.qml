

import QtQuick
import Quickshell
import "./widgets"
import "../config"
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland
Variants{
    model: Quickshell.screens
	
	delegate: PanelWindow {
		id: root
		property var modelData
        screen: modelData
		property var monitor: Hyprland.monitorFor(modelData)
		property int boxSize: 12
		property int rows: 4
		property bool visible: !monitor.activeWorkspace?.name.startsWith("wp")
		
		property var initBoxes: initVals()
		
		property int maxColNums: 21
		property int maxTotalBoxes: maxColNums * rows
		function initVals() {
			let temp = []
			for (let x = 0; x < maxColNums; x++) {
				for (let y = 0; y < rows; y++) {
					temp.push({
						id: y + x * rows,
						score: Math.random()
					})
				}
			}
			return temp
		}
		function sliceVals(len){
			let newBoxes = new Array(len)
			let temp = initBoxes.slice(0, len)
			temp.sort((a, b) => b.score - a.score)
			for (let i = 0; i < temp.length; i++) {
				newBoxes[temp[i].id] = i   
			}
			return newBoxes
		}
		Component.onCompleted: initVals()
		color: "transparent"
		anchors{
			bottom: true
			left: true
			right: true
		}
		implicitHeight: rows * boxSize
		margins{
			bottom: visible ? 0 :  -implicitHeight
		}
		Connections {
			target: Hyprland

			function onRawEvent(event) {
				if(event.name == "moveworkspace"){
					Hyprland.refreshMonitors()
					Hyprland.refreshToplevels() 
					Hyprland.refreshWorkspaces()
				}
			}
		}
		Rectangle{
			anchors.fill: parent
			color: Qt.rgba(
				Theme.bgBase.r,
				Theme.bgBase.g,
				Theme.bgBase.b,
				0.8
			)
			RowLayout{
				spacing: 0
				anchors{
					top: parent.top
					bottom: parent.bottom
					left: parent.left
				}
				NetworkBluetooth{
					boxSize: root.boxSize
					boxes: root.sliceVals(root.maxTotalBoxes)
				}
				Music{
					boxSize: root.boxSize
				}
			}
			Dock{
				boxSize: root.boxSize
				maxRowNums: root.rows
				boxes: root.sliceVals(root.maxTotalBoxes)
				maxTotalBoxes: root.maxTotalBoxes
				activeWsId: (Hyprland.monitorFor(modelData)).activeWorkspace?.id?? 0
				anchors{
					horizontalCenter: parent.horizontalCenter
					top: parent.top
					bottom: parent.bottom
				}
			}
			RowLayout{
				anchors{
					top: parent.top
					bottom: parent.bottom
					right: parent.right
				}
				spacing: 0
				SystemTray{
					window: root
					boxSize: root.boxSize
					boxes: sliceVals(4)
				}
				Idle{
					window: root
					boxSize: root.boxSize
				}
				Resources{
					boxSize: root.boxSize
					rows: 4
					cols: 5
					boxes: root.sliceVals(rows*cols)
				}
				Battery{
					boxSize: root.boxSize
					cols: 4
					rows: 4
					boxes: sliceVals(cols*rows)
				}
				VolumeBrightness{
					boxSize: root.boxSize
					
					cols: 5
					rows: 4
					boxes: sliceVals(cols*rows)
				}
				Clock{
					boxSize: root.boxSize
				}
				
			}
			
		}
	}
}


