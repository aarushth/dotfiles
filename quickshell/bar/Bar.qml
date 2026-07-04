

import QtQuick
import Quickshell
import "./widgets"
import "../config"
import QtQuick.Layouts
import Quickshell.Hyprland

PanelWindow {
	id: root
	property int boxSize: 16
	property int rows: 3
	property var focusedWorkspace: Hyprland.focusedWorkspace?? ""
	property bool visible: focusedWorkspace.name !== "wp"

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
    
	Rectangle{
		anchors.fill: parent
		color: Qt.rgba(
			Theme.bgBase.r,
			Theme.bgBase.g,
			Theme.bgBase.b,
			0.9
		)
		Dock{
			boxSize: root.boxSize
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
			Clock{
				boxSize: root.boxSize
			}
			SystemTray{
				window: root
				boxSize: root.boxSize
			}
		}
		
	}
}
