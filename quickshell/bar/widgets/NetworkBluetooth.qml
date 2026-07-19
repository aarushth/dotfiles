import Quickshell
import Quickshell.Networking
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import "../../config"


ColumnLayout{
	id: root
	required property int boxSize
	required property var boxes
	
	property var currentDevice: null
	readonly property var currentNetwork: {
		for (const device of Networking.devices.values) {
			for (const network of device.networks.values) {
				if (network.state === ConnectionState.Connected ||
					network.state === ConnectionState.Connecting) {
					currentDevice = device
					return network
				}
			}
		}
		return null
	}
	property string ipAddress: ""
	onStatusChanged: ipGrab.running = true
	property string wifiIcon: (currentNetwork?.device.type === DeviceType.Wifi) ? (status === ConnectionState.Connected ? Icons.wifiIcons[Math.round(currentNetwork.signalStrength * 4)] : status === ConnectionState.Disconnected ? Icons.wifiDisconnectedIcon : "") : Icons.ethernetIcon

	Process{
		id: ipGrab
		running: false
		command: ["nmcli", "-g", "IP4.ADDRESS", "device", "show", currentDevice?.name]
		stdout: StdioCollector {
			onStreamFinished: root.ipAddress = text.trim()
		}
	}
	property var bluetoothDevice: Bluetooth.devices.values[0]
	readonly property int status: currentNetwork?.state ?? ConnectionState.Disconnected

	function roundUp(w) {
		return Math.ceil(w / root.boxSize) * root.boxSize
	}

	width: Math.max(
		roundUp(wifiText.implicitWidth),
		roundUp(bluetoothText.implicitWidth),
		roundUp(ipText.implicitWidth)
	) + root.boxSize * 2
	
	property int cols: width/root.boxSize
	property var slicedBoxes: boxes.slice(0, 2 * cols)

	spacing: 0
	Rectangle{
		Layout.preferredWidth: parent.width
		height: boxSize * 2
		color: Theme.accentPurple
		MouseArea{
			id: bluetoothMouse
			anchors.fill:parent
			hoverEnabled: true
			onClicked: DesktopEntries.heuristicLookup("bluetui").execute()
		}
		
		
		Text{
			id: bluetoothText
			anchors{
				top: parent.top
				bottom: parent.bottom
				left: bluetoothIconText.right
			}
			anchors{
				top: parent.top
				bottom: parent.bottom
				left: wifiIconText.right
			}
			color: Theme.bgBase
			font.family: Theme.fontTitle
			font.pixelSize: 12
			font.capitalization: Font.AllUppercase
			verticalAlignment: Text.AlignVCenter
			text: bluetoothDevice?.connected ? bluetoothDevice.name : "Disconnected"
			font.styleName: "Black"
		}
		Grid{
			id: gridBluetooth
			Layout.preferredWidth: parent.Layout.preferredWidth
			Layout.preferredHeight: parent.Layout.preferredHeight
			columns: cols
			rows: 2
			property int revealInd: bluetoothMouse.containsMouse ? boxes.length : 0
			Behavior on revealInd{
				NumberAnimation{ duration: 200 }
			}
			Repeater {
				model: root.slicedBoxes.slice(0, gridBluetooth.rows * gridBluetooth.columns)
				delegate: Rectangle {
					required property int index
					width: boxSize
					height: boxSize
					property int idx: slicedBoxes[index % slicedBoxes.length]
					color: Theme.accentPurpleHover
					opacity: (idx >= parent.revealInd) ? 0 : 1
				}
			}
		}
		Text{
			id: bluetoothIconText
			text: bluetoothDevice?.connected ? Icons.bluetoothConnected : Icons.bluetoothDisconnected
			anchors{
				top: parent.top
				bottom: parent.bottom
				left: parent.left
			}
			font.pixelSize: 15
			width: root.boxSize * 2
			verticalAlignment: Text.AlignTop
			horizontalAlignment: Text.AlignHCenter
		}
		Text{
			id: batteryText
			visible: false
			anchors{
				top: parent.top
				bottom: parent.bottom
				left: bluetoothIconText.right
				right: parent.right
			}
			color: Theme.bgBase
			font.family: Theme.fontFancy
			font.pixelSize: 14
			font.capitalization: Font.MixedCase
			verticalAlignment: Text.AlignVCenter
			text: bluetoothDevice?.batteryAvailable ? "Battery " + String(Math.round(bluetoothDevice?.battery * 100)).padStart(0, 3) + "%" : "No Device Connected"
		}
		OpacityMask {
			anchors{
				top: parent.top
				bottom: parent.bottom
				left: bluetoothIconText.right
				right: parent.right
			}
			source: batteryText
			maskSource: gridBluetooth
		}
	}
	Rectangle{
		Layout.preferredWidth: parent.width
		height: boxSize * 2
		color: Theme.accentPurple
		MouseArea{
			id: wifiMouse
			anchors.fill:parent
			hoverEnabled: true
			onClicked: DesktopEntries.heuristicLookup("wifitui").execute()
		}

		Text{
			id: wifiText
			anchors{
				top: parent.top
				bottom: parent.bottom
				left: wifiIconText.right
			}
			color: Theme.bgBase
			font.family: Theme.fontTitle
			font.pixelSize: 12
			font.capitalization: Font.AllUppercase
			verticalAlignment: Text.AlignVCenter
			text: currentNetwork?.name ?? "Disconnected"
			font.styleName: "Black"
		}
		
		Grid{
			id: gridWifi
			Layout.preferredWidth: parent.Layout.preferredWidth
			Layout.preferredHeight: parent.Layout.preferredHeight
			columns: cols
			rows: 2
			
			property int revealInd: wifiMouse.containsMouse ? boxes.length : 0

			Behavior on revealInd {
				NumberAnimation { duration: 200 }
			}
			Repeater {
				model: slicedBoxes
				delegate: Rectangle {
					required property int index
					width: boxSize
					height: boxSize
					property int idx: slicedBoxes[index % slicedBoxes.length]
					color: Theme.accentPurpleHover
					opacity: (idx >= parent.revealInd) ? 0 : 1
				}
			}
		}
		Text{
			id: wifiIconText
			text: wifiIcon
			anchors{
				top: parent.top
				bottom: parent.bottom
				left: parent.left
			}
			topPadding: 2
			width: root.boxSize * 2
			verticalAlignment: Text.AlignTop
			horizontalAlignment: Text.AlignHCenter
		}

		Text{
			id: ipText
			anchors{
				top: parent.top
				bottom: parent.bottom
				left: wifiIconText.right
				right: parent.right
			}
			visible: false
			color: Theme.bgBase
			font.family: Theme.fontFancy
			font.pixelSize: 12
			font.capitalization: Font.MixedCase
			verticalAlignment: Text.AlignVCenter
			text: (currentDevice?.name + " via " + ipAddress) ?? "Disconnected"
		}
		
		OpacityMask {
			anchors{
				top: parent.top
				bottom: parent.bottom
				left: wifiIconText.right
				right: parent.right
			}
			source: ipText
			maskSource: gridWifi
		}
	}	
}
