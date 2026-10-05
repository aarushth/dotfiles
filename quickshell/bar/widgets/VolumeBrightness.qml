import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../config"
import "../../components"

ColumnLayout {
    id: root
    spacing: 0
    required property var window
    property int boxSize: Boxes.boxSize
    property var boxes: []
    Component.onCompleted: boxes = Boxes.getBoxes(rows * cols / 2)
    Layout.preferredHeight: parent.height
    property int cols: 5
    property int rows: 4
    width: boxSize * cols
    property string volume: String(Math.round(OsdData.volume * 100))
    property string brightness: String(Math.round(OsdData.brightness * 100))
    property string volumeText: Icons.getVolumeIcon(volume, OsdData.muted) + " " + volume.padStart(3, "0") + "%"
    property string brightnessText: Icons.brightnessIcons[Math.ceil(brightness / 10)] + " " + brightness.padStart(3, "0") + "%"
    HyprlandFocusGrab {
        id: grab
        windows: [popup]
        active: popup.backingWindowVisible
        onCleared: popup.visible = false
    }
    PopupWindow {
        id: popup
        implicitWidth: Math.max(popupRoot.implicitWidth, 1)
        implicitHeight: Math.max(popupRoot.implicitHeight, 1)

        anchor {
            window: root.window
            item: root
            edges: Edges.Top
            gravity: Edges.Top
        }
        PopupMenu {
            id: popupRoot
            PopupItem {
                text: Icons.micIcon + " Default Audio Source"
                hoverEnabled: false
                Layout.fillWidth: true
            }
            Repeater {
                model: OsdData.sourceNodes
                delegate: PopupItem {
                    required property var modelData
                    text: modelData.description
                    emphasized: modelData == OsdData.defaultAudioSource
                    onClicked: OsdData.setPreferredSource(modelData)
                    Layout.fillWidth: true
                }
            }
            PopupItem {
                isSeparator: true
                emphasized: false
                Layout.fillWidth: true
            }
            PopupItem {
                text: Icons.getVolumeIcon(100) + " Default Audio Sink"
                emphasized: true
                hoverEnabled: false
                Layout.fillWidth: true
            }
            Repeater {
                model: OsdData.sinkNodes
                delegate: PopupItem {
                    required property var modelData
                    text: modelData.description
                    emphasized: modelData == OsdData.defaultAudioSink
                    onClicked: OsdData.setPreferredSink(modelData)
                    Layout.fillWidth: true
                }
            }
        }
    }
    Repeater {
        model: [root.volumeText, root.brightnessText]
        delegate: Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Grid {
                id: grid
                anchors.fill: parent
                columns: root.cols
                rows: root.rows / 2
                property int revealInd: mouse.containsMouse ? root.boxes.length : 0
                Behavior on revealInd {
                    NumberAnimation {
                        duration: 300
                    }
                }
                Repeater {
                    model: root.cols * root.rows / 2
                    delegate: Rectangle {
                        required property int index
                        width: root.boxSize
                        height: root.boxSize
                        property int idx: root.boxes[index]
                        color: (idx < grid.revealInd) ? Theme.accentPurpleHover : Theme.accentPurple
                    }
                }
            }
            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button == Qt.RightButton) {
                        if (index == 0) {
                            popup.visible = !popup.visible;
                        }
                    } else {
                        Quickshell.execDetached(["qs", "ipc", "call", "osd", index == 0 ? "volume" : "brightness"]);
                    }
                }
            }
            Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: modelData
                font.family: Theme.fontNormal || Theme.fontIcon
                font.pixelSize: 14
                color: Theme.bgBase
            }
        }
    }
}
