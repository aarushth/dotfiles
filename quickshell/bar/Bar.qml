

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
		property bool visible: !monitor.activeWorkspace?.name.startsWith("wp")
		color: "transparent"
		anchors{
			bottom: true
			left: true
			right: true
		}
		implicitHeight: 4 * Boxes.boxSize
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
				NetworkBluetooth{}
				Music{}
			}
			Dock{
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
				}
				Idle{
					window: root
				}
				Resources{}
				Battery{}
				VolumeBrightness{}
				Clock{}
				
			}
			
		}
	}
}


