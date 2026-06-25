import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Wayland
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

Item {
    id: root
    width: Screen.width

	property bool shouldShowPicker : false
	readonly property real itemWidth: 400
    readonly property real itemHeight: 420
    readonly property real borderWidth: 3
    readonly property real spacing: 10
    readonly property real skewFactor: -0.35
	property real scrollThreshold: 150
	property int scrollAccum: 0
	property bool closing: false

	IpcHandler {
		target: "wallpaper"

		function open() {
			root.shouldShowPicker = true
			closing = false
		}
		function close(){
			root.shouldShowPicker = false
		}
	}
	property string url: ""
    function applyWallpaper(fileUrl) {
		switchAnim.running = true
		root.url = fileUrl.toString().substring(7)
    }
    readonly property string srcDir: {
        const dir = Quickshell.env("WALLPAPER_DIR")
        return (dir && dir !== "") 
        ? dir 
        : Quickshell.env("HOME") + "/Pictures/Wallpaper"
    }
	Process {
		id: wallpaperLoader
		running: true
		command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/config/current_wallpaper"]

		stdout: SplitParser {
			onRead: data => {
				let path = data.trim()
				if (path !== "") {
					// console.warn(path)
					root.url = path
					root.shouldShowPicker = true
					closing = true
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
		PanelWindow{
			id: window
			anchors {
				top: true
				right: true
				bottom: true
				left: true
			}
			margins{
				left: 0
			}
			WlrLayershell.namespace: "quickshell-wallpaper-picker"
			WlrLayershell.layer: WlrLayer.Background
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

			color: "transparent"
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
						color: "black"
						opacity: (idx < root.revealInd) ? 1 : 0

					}
				}
			}
			ListView {
				id: view
				width: screen.width * 1.5
				height: root.itemHeight
				anchors.centerIn: parent

				orientation: ListView.Horizontal

				highlightRangeMode: ListView.StrictlyEnforceRange

				preferredHighlightBegin: (width / 2) - ((root.itemWidth * 1.5 + root.spacing) / 2)
				preferredHighlightEnd: (width / 2) + ((root.itemWidth * 1.5 + root.spacing) / 2)

				highlightMoveDuration: 500
				focus: true

				model: srcModel
				spacing: root.spacing

				// currentIndex: 
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
					// console.warn(event.key)
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

					

					width: targetWidth -root.spacing
					height: targetHeight

					

					Behavior on targetWidth { enabled: true; NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }

					Item {
						id: skewMask
						anchors.centerIn: parent
						anchors.horizontalCenterOffset: (root.itemHeight * 0.5 * -root.skewFactor) + root.spacing + 0.5
						property bool entered: false
						width: targetWidth
						height: root.closing ? 0 : (entered ? targetHeight : 0)
						visible: height > 20
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
								// TODO apply wallpaper
							}
						}

						Item {
							anchors.fill: parent
							anchors.margins: root.borderWidth
							clip: true

							Image {
								anchors.centerIn: parent
								anchors.horizontalCenterOffset: -50
								width: (root.itemWidth * 1.5) + ((root.itemHeight) * Math.abs(root.skewFactor)) + 50
								height: root.itemHeight
								fillMode: Image.PreserveAspectCrop
								source: fileUrl
								transform: Matrix4x4 {
									property real s: -root.skewFactor
									matrix: Qt.matrix4x4(1, s, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
								}
								Component.onCompleted: skewMask.entered = true

							}
						}
					}
				}
			}
		}
	}
}