import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects
import QtQuick.Studio.Components
import "../../config"

RowLayout{
	id: root
	
	required property int boxSize
	property int maxRowNums: 3
	property int maxColNums: 21
	property int maxTotalBoxes: maxColNums * maxRowNums
	property var boxes: null
	property var transitionDuration: 200
	function initVals() {
        var temp = []
        let newBoxes = new Array(maxTotalBoxes)
        
        for (let x = 0; x < maxColNums; x++) {
            for (let y = 0; y < maxRowNums; y++) {
                temp.push({
                    id: y * maxColNums + x,
                    score: Math.random()
                })
            }
        }
        temp.sort((a, b) => b.score - a.score)
        for (let i = 0; i < temp.length; i++) {
            newBoxes[temp[i].id] = i    
        }    
		boxes = newBoxes
    }
	Layout.preferredHeight: parent.height
	
	Component.onCompleted: initVals()
	spacing: 0
	Repeater {
		model: Hyprland.workspaces
		delegate: Rectangle{
			id: wsBound
			property var ws: modelData
			property var cols: (ws.toplevels.values.length * 2) + 1
			property var w: (cols) * root.boxSize
			property var totalBoxes: cols * root.maxRowNums
			property var boxes: root.boxes.slice(0, totalBoxes)
			Layout.preferredHeight: parent.height
			Layout.preferredWidth: w
			color: "transparent"
			property var active: ws.active
			property var revealInd: 0
			visible: ws.toplevels.values.length > 0
			onActiveChanged: {
				if(active){
					exitAnim.restart()
				}else{
					entryAnim.restart()
				}
				
			}
			NumberAnimation{
				id: entryAnim
				target: wsBound
				property: "revealInd"
				from: 0
				to: root.maxTotalBoxes
				duration: root.transitionDuration
				running: false
			}
			NumberAnimation{
				id: exitAnim
				target: wsBound
				property: "revealInd"
				to: 0
				from: root.maxTotalBoxes
				duration: root.transitionDuration
				running: false
			}
			MouseArea{
				id: mouse
				anchors.fill:parent
				hoverEnabled: true
				onClicked: ws.activate()
			}
			Item{
				id: gridContainer
				anchors.fill: parent
				visible: false
				Grid{
					id: grid
					Layout.preferredWidth: parent.Layout.preferredWidth
					Layout.preferredHeight: parent.Layout.preferredHeight
					columns: wsBound.cols
					rows: root.maxRowNums
					
					Repeater {
						model: wsBound.totalBoxes
						delegate: Rectangle {
							required property int index
							width: root.boxSize
							height: root.boxSize
							property int idx: index < wsBound.boxes.length ? wsBound.boxes[index] : -1
							color: Theme.accentPurple
							opacity: (idx < wsBound.revealInd) ? (mouse.containsMouse ? 0.8 : 1) : 0
						}
					}
				}
			}
			Item{
				id: gridInverseContainer
				anchors.fill: parent
				visible: false
				Grid{
					id: gridInverse
					Layout.preferredWidth: parent.Layout.preferredWidth
					Layout.preferredHeight: parent.Layout.preferredHeight
					columns: wsBound.cols
					rows: root.maxRowNums
					Repeater {
						model: wsBound.totalBoxes
						delegate: Rectangle {
							required property int index
							width: root.boxSize
							height: root.boxSize
							property int idx: index < wsBound.boxes.length ? wsBound.boxes[index] : -1
							color: Theme.accentPurple
							opacity: (idx >= wsBound.revealInd) ? 1 : 0
						}
					}
				}
			}
			Item{
				id: iconContainer
				anchors.fill: parent
				visible: false
				ColumnLayout{
					spacing: 0
					TextItem{
						id: iconsText
						Layout.preferredHeight: root.boxSize * 2
						Layout.preferredWidth: wsBound.w
						text: modelData.toplevels.values.map(toplevel => Icons.get(toplevel.wayland.appId?? "" ) ?? Icons.get(toplevel.title) ?? "").join(" ")
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
						font.pixelSize: root.boxSize * 2 - 10
						fillColor: Theme.accentPurple
						strokeColor: "transparent"
						font.family: "Symbols Nerd Font Mono"
					}
					Text{
						Layout.preferredHeight: root.boxSize
						Layout.preferredWidth: wsBound.w
						color: Theme.accentPurple
						text: modelData.name ?? modelData.id
						font.family: Theme.fontFancy
						font.bold: true
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}
				}
			}
			OpacityMask {
				id: maskOne
				anchors.fill: parent
				source: gridContainer
				maskSource: iconContainer
				invert: true
			}
			OpacityMask {
				id: maskTwo
				anchors.fill: parent
				source: gridInverseContainer
				maskSource: iconContainer
			}
		}
	}
}
