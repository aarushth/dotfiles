import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Wayland
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../config"

Item {
    id: root
	property bool shouldShowPicker: false
	readonly property real itemWidth: 400
    readonly property real itemHeight: 420
    readonly property real spacing: 10
    readonly property real skewFactor: 0.35
	property real scrollThreshold: 150
	property int scrollAccum: 0
	property bool closing: false

	IpcHandler {
		target: "wallpaper"
		function toggle(){
			closing = root.shouldShowPicker
			root.shouldShowPicker = true
			if(closing){
				closeTimer.start()
			}
		}
	}
	Timer {
		id: closeTimer
		running: false
		interval: 400
		onTriggered: {root.shouldShowPicker = false}
	}
	property string url: ""
    function applyWallpaper(fileUrl) {
		switchAnim.running = true
		root.url = fileUrl.toString().substring(7)
    }
    readonly property string srcDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
	Process {
		id: wallpaperLoader
		running: true
		command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/config/current_wallpaper"]

		stdout: SplitParser {
			onRead: data => {
				let path = data.trim()
				if (path !== "") {
					root.url = path
				}
			}
		}
	}
	property bool animating: false
	SequentialAnimation{
		id: switchAnim
		running: false
		ScriptAction{
			script: {
				root.closing = true
				animating = true
			}
		}
		PauseAnimation{
			duration: 1000
		}
		ScriptAction{ 
			script: {
				Quickshell.execDetached(["awww", "img", url, "--transition-type", "none"])
				Quickshell.execDetached([
					"sh",
					"-c",
					`printf '%s\n' "$1" > ~/.config/quickshell/config/current_wallpaper`,
					"--",
					url
				])
			}
		}
		PauseAnimation{
			duration: 400
		}
		ScriptAction{
			script: animating = false
		}
		PauseAnimation{
			duration: 1000
		}
		ScriptAction{
			script: root.shouldShowPicker = false
		}
	}
    

	FolderListModel {
		id: srcModel
		folder: "file://" + root.srcDir
		nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif"]
		showDirs: false
	}
	Loader {
		id: loader
		active: root.shouldShowPicker
		Item{
			FloatingWindow{
				visible: root.shouldShowPicker
				id: window
				title: "quickshell-wallpaper-picker"
				color: "transparent"
				ListView {
					id: view
					model: srcModel
					width: Screen.width * 1.5
					height: root.itemHeight
					anchors.centerIn: parent

					orientation: ListView.Horizontal

					highlightRangeMode: ListView.StrictlyEnforceRange

					preferredHighlightBegin: (width / 2) - ((root.itemWidth * 1.5) / 2)
					preferredHighlightEnd: (width / 2) + ((root.itemWidth * 1.5 ) / 2)
					property int extraSkew: root.itemWidth * skewFactor * 2 + root.spacing*2
					highlightMoveDuration: 500
					focus: true
					spacing: -extraSkew + (root.spacing*2)

					Component.onCompleted: {
						let savedPath = root.url
						for (let i = 0; i < srcModel.count; ++i) {
							let filePath = srcModel.get(i, "filePath") // or fileUrl.toLocalFile()
							if (filePath === savedPath) {
								view.currentIndex = i
								break
							}
						}
					}
					Keys.onPressed: (event)=> { 
						if (event.key == Qt.Key_Return) {
							let url = srcModel.get(view.currentIndex, "fileUrl")
							root.applyWallpaper(url)
						}
					}
					WheelHandler{
						acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
						orientation: Qt.Horizontal

						onWheel: (wheel) => {
							if(root.isItemAnimating){
								event.accepted = true
								return
							}
							let dx = wheel.pixelDelta.x
							let dy = wheel.pixelDelta.y
							let delta = Math.abs(dx) > Math.abs(dy) ? dx : dy

							scrollAccum += delta
							if (Math.abs(scrollAccum) >= root.scrollThreshold) {
								view.currentIndex += scrollAccum > 0 ? -1 : 1
								scrollAccum = 0
							}

							wheel.accepted = true
						}        
					}

					delegate: Item {
						id: delegateRoot
						readonly property bool isVisuallyEnlarged: ListView.isCurrentItem
						property real targetWidth: isVisuallyEnlarged ? root.itemWidth * 1.5 : root.itemWidth * 0.5
						readonly property real targetHeight: root.itemHeight

						
						width: targetWidth + view.extraSkew
						height: targetHeight
						clip: true

						Behavior on targetWidth { enabled: true; NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
						Item{

							id: skewMask
							anchors.centerIn: parent
							
							width: parent.width
							
							height: targetHeight
							property bool startAnimation: false
							
							Rectangle{
								anchors.centerIn: parent
								width: targetWidth
								height: root.closing ? 0 : (parent.startAnimation ? targetHeight : 0)
								Behavior on height {
									NumberAnimation {
										duration: 200
									}
								}
								// color: "transparent"
								visible: true
								
								transform: Matrix4x4 {
									property real s: root.skewFactor
									matrix: Qt.matrix4x4(
										1, s, 0, 0,
										0, 1, 0, 0,
										0, 0, 1, 0,
										0, 0, 0, 1
									)
								}
								
								MouseArea {
									anchors.fill: parent
									onClicked: {
										if(view.currentIndex != index){
											view.currentIndex = index
										}else{
											root.applyWallpaper(fileUrl)
										}
									}
								}
							}
						}
						Item {
							id: imageContainer
							anchors.centerIn: parent
							width: parent.width
							height: targetHeight
							visible: true
							opacity: 0
							Image {
								id: image
								anchors.centerIn: parent
								anchors.horizontalCenterOffset: -50
								width: parent.width + view.extraSkew
								height: root.itemHeight
								fillMode: Image.PreserveAspectCrop
								source: fileUrl
								cache: false
								visible: image.status == Image.Ready
								asynchronous: true
								onStatusChanged: {
									
									if (image.status == Image.Ready) {
										skewMask.startAnimation = true
									}else{
										skewMask.startAnimation = false
									}
								}
								
							}
						}
						OpacityMask{
							anchors.centerIn: parent
							width: parent.width
							height: targetHeight
							maskSource: skewMask
							source: imageContainer
							
						}
					}
				}
			}
			Variants{
				model: Quickshell.screens
				delegate: PanelWindow {
					id: gridWindow
					property var modelData
					screen: modelData
					visible: root.shouldShowPicker
					property int boxSize: 20
					property int colNums: modelData.width/boxSize
					property int rowNums: modelData.height/boxSize
					property int totalBoxes: colNums * rowNums
					property int revealInd: root.animating ? totalBoxes : 0
					Behavior on revealInd{
						NumberAnimation{ duration: 1000 }
					}
					property var gridRef: null
					
					property var boxes: {
						var temp = []
						let box = new Array(totalBoxes)
						
						for (let x = 0; x < colNums; x++) {
							for (let y = 0; y < rowNums; y++) {
								let bias = Math.abs(y - (rowNums / 2)) / rowNums
								temp.push({
									id: y * colNums + x,
									score: Math.random() * 0.1 + bias * 0.9
								})
							}
						}
						temp.sort((a, b) => b.score - a.score)
						for (let i = 0; i < temp.length; i++) {
							box[temp[i].id] = i	
						}
						return box
					}
					exclusionMode: ExclusionMode.Ignore
					WlrLayershell.layer: WlrLayer.Overlay
					WlrLayershell.keyboardFocus: WlrKeyboardFocus.None	
					WlrLayershell.namespace: "quickshell-lockscreen"
					anchors{
						top: true
						bottom: true
						left: true
						right: true
					}
					color: "transparent"
					Grid {
						id: grid
						anchors.fill: parent
						columns: colNums
						rows: rowNums
						visible: true
		
						Repeater {
							model: totalBoxes

							delegate: Rectangle {
								width: boxSize
								height: boxSize
								property int idx: 100000
								Component.onCompleted: idx = gridWindow.boxes[index]
								color: Theme.accentPurple
								opacity: (idx < gridWindow.revealInd) ? 1 : 0

							}
						}
					}
				}
			}
		}
	}
}