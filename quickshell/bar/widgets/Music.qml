import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick.Layouts
import QtQuick
import QtQuick.Controls
import "../../config"
Item{
	id: root
	property int boxSize: Boxes.boxSize
	property var boxes: []
	Component.onCompleted: boxes = Boxes.getBoxes(boxNums)
	property int rows: 8
	property int cols: 24
	property int boxNums: rows*cols / 4
	property int revealInd: base.hovered ? 0 : boxNums

	property var player: {
		for(const player of Mpris.players.values){
			if(player.desktopEntry == "spotify"){
				return player
			}
		}
		return undefined
	}
	Behavior on revealInd{
		NumberAnimation{ duration: 300 }
	}
	Layout.preferredHeight: parent.height 
	Layout.preferredWidth: cols * boxSize / 2
	
	Rectangle{
		anchors.fill: parent
		color: Theme.accentPurpleHover
		Item{
			visible: player != undefined
			anchors.fill: parent
			Image{
				id: art
				anchors{
					top: parent.top
					left: parent.left
					margins: root.boxSize / 2
				}
				source: player?.trackArtUrl ?? ""
				height: parent?.height - root.boxSize
				width: parent?.height - root.boxSize
			}
			Item{
				id: titleContainer
				anchors{
					top: parent.top
					left: art.right
					right: parent.right
					margins: root.boxSize / 2
				}
				clip: true
				height: titleText.implicitHeight
				Text{
					id: titleText
					anchors.fill: parent
					property real pos: 0
					readonly property bool shouldScroll: titleMetrics.width > width
					text: title + (shouldScroll ? "   " + title : "")
					transform: [
						Translate{ x: titleText.pos }
					]
					NumberAnimation{
						id: numAnim
						loops: Animation.Infinite
						target: titleText
						property: "pos"
						from: 0
					}
					property string title: player?.trackTitle ?? ""
					Component.onCompleted: Qt.callLater(onChange)
					onTitleChanged: Qt.callLater(onChange)
					function onChange(){
						numAnim.stop()
						pos = 0
						if(shouldScroll){ 
							numAnim.to = -(titleText.implicitWidth - titleMetrics.width)
							numAnim.duration = Math.round(10 * titleMetrics.width * 2)
							numAnim.restart()
						}
					}
					font.family: Theme.fontTitle
					
					font.pixelSize: 10
					font.capitalization: Font.AllUppercase
					font.styleName: "Black"
					TextMetrics {
						id: titleMetrics
						font.family: Theme.fontTitle
						font.pixelSize: 10
						text: titleText.title
						font.capitalization: Font.AllUppercase
						font.styleName: "Black"
					}
				}
			}
			Item{
				anchors{
					top: titleContainer.bottom
					left: art.right
					right: parent.right
					bottom: parent.bottom
					margins: root.boxSize / 2
					topMargin: 0
				}
				Item{
					id: prev
					anchors{
						top: parent.top
						bottom: parent.bottom
						left: parent.left
					}
					width: parent.width/3
					Text{
						anchors.fill: parent
						text: "󰒮"
						horizontalAlignment: Text.AlignRight
						verticalAlignment: Text.AlignVCenter
						font.family: Theme.fontIcon
						font.pixelSize: prevHover.containsMouse ? 13 : 10
					}
					MouseArea{
						id: prevHover
						anchors.fill: parent
						hoverEnabled: true
						propagateComposedEvents: true
						onClicked: player.previous()
					}
				}
				Item{
					id: play
					anchors{
						top: parent.top
						bottom: parent.bottom
						left: prev.right
					}
					width: parent.width/3
					Text{
						anchors.fill: parent
						text: player?.isPlaying ? "󰏤" : "󰐊"
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
						font.family: Theme.fontIcon
						font.pixelSize: playHover.containsMouse ? 13 : 10
					}
					MouseArea{
						id: playHover
						anchors.fill: parent
						hoverEnabled: true
						onClicked: player.togglePlaying()
					}
				}
				Item{
					anchors{
						top: parent.top
						bottom: parent.bottom
						left: play.right
					}
					width: parent.width/3
					Text{
						anchors.fill: parent
						text: "󰒭"
						horizontalAlignment: Text.AlignLeft
						verticalAlignment: Text.AlignVCenter
						font.family: Theme.fontIcon
						font.pixelSize: nextHover.containsMouse ? 13 : 10 
					}
					MouseArea{
						id: nextHover
						anchors.fill: parent
						hoverEnabled: true
						propagateComposedEvents: true
						onClicked: player.next()
					}
				}
			}
		}
		Item{
			visible: player === undefined
			anchors.fill: parent
			Text{
				id: icon
				anchors{
					top: parent.top
					bottom: parent.bottom
					left: parent.left
				}
				width: parent.width/3
				text: Icons.get("spotify")
				font.family: Theme.fontIcon
				verticalAlignment: Text.AlignVCenter
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: 30
			}
			Text{
				anchors{
					top: parent.top
					bottom: parent.bottom
					left: icon.right
					right: parent.right
				}
				text: "Launch Spotify"
				font.family: Theme.fontFancy
				font.pixelSize: 18
				wrapMode: Text.WordWrap
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
			}
			MouseArea{
				anchors.fill: parent
				onClicked: DesktopEntries.byId("com.spotify.Client").execute()
			}
		}
	}
	Grid{
		columns: root.cols
		rows: root.rows
		Repeater{
			model: rows * cols
			delegate: Rectangle{
				property int col: Math.floor(index % root.cols)
				property int halfCol: col/2
				property int row: Math.floor(index / root.cols)
				property int halfRow: row/2
				width: root.boxSize/2
				height: root.boxSize/2
				color: (root.rows-row) <= Media.cavaVals[col] ? Theme.accentPurpleHover : Theme.accentPurple
				opacity: boxes[(halfRow * root.cols / 2) + halfCol] < revealInd ? 1 : 0
			}
		}
	}
	HoverHandler{
		id: base
	}

}
