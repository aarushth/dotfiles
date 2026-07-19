import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Wayland
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import "../config"

Item {
    id: root
    width: Screen.width
	property bool shouldShowPicker: false
	readonly property real itemWidth: 400
    readonly property real itemHeight: 420
    readonly property real spacing: 5
    readonly property real skewFactor: -0.35
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
	property var boxes: []
    property int boxSize: 20
	property int colNums: Screen.width/boxSize
    property int rowNums: Screen.height/boxSize
	property int totalBoxes: colNums * rowNums
	property int revealInd: 0
	property var gridRef: null
	
    function initVals() {
        var temp = []
        boxes = new Array(totalBoxes)
        
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
            boxes[temp[i].id] = i    
        }
        
    }
	Component.onCompleted: initVals()
	SequentialAnimation{
		id: switchAnim
		running: false
		ScriptAction{
			script: {
				root.closing = true
				root.gridRef.visible = true
			}
		}
		NumberAnimation{
			target: root
			property: "revealInd"
			from: 0; to: root.totalBoxes
			duration: 1000
			easing.type: Easing.OutCubic
			running: false
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
			duration: 100
		}
		NumberAnimation{
			target: root
			property: "revealInd"
			from: root.totalBoxes; to: 0
			duration: 1000
			easing.type: Easing.InCubic
			running: false
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
	LazyLoader {
		id: loader
		active: root.shouldShowPicker
		Component.onCompleted: {root.shouldShowPicker = false}
		FloatingWindow{
			id: window
			title: "quickshell-wallpaper-picker"
			color: "transparent"
			// Component.onCompleted: {
			// 	window.grabFocus()
			// }
			
			
			Grid {
				id: grid
				anchors.fill: parent
				columns: colNums
				rows: rowNums
				visible: false
				Component.onCompleted: root.gridRef = grid
				Repeater {
					model: totalBoxes

					delegate: Rectangle {
						width: boxSize
						height: boxSize
						property int idx: 100000
						Component.onCompleted: idx = root.boxes[index]
						color: Theme.accentPurple
						opacity: (idx < root.revealInd) ? 1 : 0

					}
				}
			}
			ListView {
				id: view
				model: srcModel
				width: screen.width * 1.5
				height: root.itemHeight
				anchors.centerIn: parent

				orientation: ListView.Horizontal

				highlightRangeMode: ListView.StrictlyEnforceRange

				preferredHighlightBegin: (width / 2) - ((root.itemWidth * 1.5) / 2)
				preferredHighlightEnd: (width / 2) + ((root.itemWidth * 1.5 ) / 2)

				highlightMoveDuration: 500
				focus: true
				property int loadedImages: 0
				property bool startAnimation: loadedImages >= srcModel.count
				spacing: 0

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

					readonly property bool isCurrent: ListView.isCurrentItem
					readonly property bool isVisuallyEnlarged: isCurrent

					property real targetWidth: isVisuallyEnlarged ? root.itemWidth * 1.5 : root.itemWidth * 0.5

					readonly property real targetHeight: root.itemHeight

					
					width: targetWidth
					height: targetHeight

					

					Behavior on targetWidth { enabled: true; NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }

					Item {
						id: skewMask
						anchors.centerIn: parent
						anchors.horizontalCenterOffset: (root.itemHeight * 0.5 * -root.skewFactor) + 0.5
						property bool entered: false
						width: targetWidth
						height: root.closing ? 0 : (view.startAnimation ? targetHeight : 0)
						visible: view.startAnimation && height > 20
						Behavior on height {
							NumberAnimation {
								duration: 400
							}
						}
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

						Item {
							anchors.fill: parent
							anchors.margins: root.spacing
							clip: true

							Image {
								id: image
								anchors.centerIn: parent
								anchors.horizontalCenterOffset: -50
								width: (root.itemWidth * 1.5) + ((root.itemHeight) * Math.abs(root.skewFactor)) + 50
								height: root.itemHeight
								fillMode: Image.PreserveAspectCrop
								source: fileUrl
								cache: true
								transform: Matrix4x4 {
									property real s: -root.skewFactor
									matrix: Qt.matrix4x4(1, s, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
								}
								onStatusChanged: {
									if (image.status == Image.Ready) {
										view.loadedImages++
									}
								}
								 
							}
						}
					}
				}
			}
		}
	}
}