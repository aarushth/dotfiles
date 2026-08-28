import QtQuick
import QtQuick.Layouts
import QtQuick.Studio.Components
import Quickshell.Wayland
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import "../config"
Scope {
	id: root
	property int mode : OsdData.Mode.Volume
	property bool shouldShowOsd: false
	property int colNums: 80
	property int rowNums: 5
	property int totalBoxes: colNums * rowNums
    property bool muted: OsdData.muted
    property bool micMuted: OsdData.micMuted
    property real micVol: micMuted ? 0.0 : 1.0
	property real volume: OsdData.volume
	property real brightness: OsdData.brightness
    property string labelText: {
        if(mode == OsdData.Mode.Volume){
            return "VOLUME: " +  (muted ? "MUTED" : String(Math.round(volume*100)).padStart(3, "0")+ "%") 
        } else if (mode == OsdData.Mode.Brightness){
            return "BRIGHTNESS: " +  String(Math.round(brightness*100)).padStart(3, "0")+ "%"
        } else if (mode == OsdData.Mode.Mic){
            return "MIC: " + (micMuted ? "MUTED" : "UNMUTED")
        }
    }
	property color strokeColor: Theme.textPrimary
    property color fillColor: {
        if(mode == OsdData.Mode.Volume){
            return (muted ? Theme.textMuted : Theme.accentPurple)
        } else if (mode == OsdData.Mode.Brightness){
            return Theme.accentGreen
        }else if (mode == OsdData.Mode.Mic){
            return (micMuted ? Theme.textMuted : Theme.accentOrange)
        }
    }
	
    property real percent: {
        if(mode == OsdData.Mode.Volume){
            return volume
        }else if(mode == OsdData.Mode.Brightness){
            return brightness
        }else if(mode == OsdData.Mode.Mic){
            return micVol    
        }
    }
    property int revealInd: percent * totalBoxes
	property bool initialized: false
    Behavior on volume{
		NumberAnimation{ duration: 200 }
	}
    Behavior on micVol{
        NumberAnimation{ duration: 900 }
    }
	Behavior on brightness{
		NumberAnimation{ duration: 200 }
	}
    Connections{
        target: OsdData
        function onShow(m){
            mode = m
            shouldShowOsd = true
            hideTimer.restart()
        }  
    }
	Timer {
		id: hideTimer
		interval: 1500
		onTriggered: {
			root.shouldShowOsd = false
		}
	}
	property var boxes: []
	function biasFunc(index){
		return (colNums - index % colNums) / colNums
	}

	Component.onCompleted: {

		boxes = Boxes.getBoxes(totalBoxes, biasFunc, "osd")
		initialized = true
	}

	LazyLoader {
		active: root.shouldShowOsd
		Variants{
			model: Quickshell.screens
			delegate: PanelWindow {
				id: window
				property var modelData
				property int boxSize: screen.width / colNums
				screen: modelData
				WlrLayershell.layer: WlrLayer.Overlay
				WlrLayershell.namespace: "quickshell-osd"
				anchors.top: true
				exclusiveZone: 0
				implicitWidth: screen.width
				implicitHeight: boxSize * rowNums
				color: "transparent"
				Item {
					id: fadeRoot
					anchors.fill: parent
					visible: true

					TextItem {
						id: textBottom
						anchors.fill: parent
						text: labelText
						font.family: Theme.fontFancy
						font.pointSize: window.implicitHeight * 0.9			
						horizontalAlignment: Text.AlignHCenter
						fillColor: "transparent"
						strokeColor: root.fillColor
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
									property int idx: 100000
									Component.onCompleted: idx = root.boxes[index]
									color: root.fillColor
									opacity: (idx < root.revealInd) ? 1 : 0

								}
							}
						}
					}

					TextItem {
						id: textTop
						anchors.fill: parent
						text: labelText
						font.family: Theme.fontFancy
						horizontalAlignment: Text.AlignHCenter
						font.pointSize: window.implicitHeight * 0.9	
						font.bold: true
						fillColor: root.strokeColor
						strokeStyle: 0
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

}
