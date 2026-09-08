import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Hyprland
import "../../config"
import "../../components"

Rectangle {
    id: tray
    required property var window
    property var boxSize: Boxes.boxSize
    implicitWidth: gridOuter.implicitWidth
    implicitHeight: parent.height
    color: Theme.accentPurple

    property var boxes: []
    Component.onCompleted: boxes = Boxes.getBoxes(4)

    GridLayout {
        id: gridOuter
        anchors.fill: parent
        rows: 2
        rowSpacing: 0
        columnSpacing: 0
        flow: GridLayout.TopToBottom
        Layout.preferredHeight: parent.height
        QsMenuOpener {
            id: menuOpener
        }
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
            visible: false
            onVisibleChanged: {
                if (visible) {
                    popupRoot.selectByDefault();
                }
            }
            anchor {
                window: tray.window
                item: tray
                edges: Edges.Top
                gravity: Edges.Top
            }
            PopupMenu {
                id: popupRoot
                onDismiss: popup.visible = false
                Repeater {
                    model: menuOpener.children
                    delegate: PopupItem {
                        required property int index
                        required property var modelData
                        isSeparator: modelData.isSeparator
                        emphasized: modelData.enabled
                        hoverEnabled: modelData.enabled
                        icon: modelData.icon
                        text: modelData.text
                        onClicked: modelData.triggered()
                        Layout.fillWidth: true
                    }
                }
            }
        }
        Repeater {
            id: iconRepeater
            model: SystemTray.items
            delegate: Item {
                id: trayItem
                width: boxSize * 2
                height: boxSize * 2
                Grid {
                    id: grid
                    anchors.fill: parent
                    columns: 2
                    rows: 2
                    property int revealInd: mouse.containsMouse ? boxes.length : 0
                    Behavior on revealInd {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                    Repeater {
                        model: 4
                        delegate: Rectangle {
                            required property int index
                            width: boxSize
                            height: boxSize
                            property int idx: boxes[index]
                            color: (idx < grid.revealInd) ? Theme.accentPurpleHover : Theme.accentPurple
                        }
                    }
                }
                Image {
                    source: modelData.icon
                    anchors.centerIn: parent
                    width: boxSize * 1.2
                    height: boxSize * 1.2
                    asynchronous: true
                }
                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            if (menuOpener.menu != modelData.menu) {
                                menuOpener.menu = modelData.menu;
                                popup.visible = true;
                            } else {
                                popup.visible = !popup.visible;
                            }
                        } else if (mouse.button === Qt.LeftButton) {
                            modelData.activate();
                        } else if (mouse.button === Qt.MiddleButton) {
                            modelData.secondaryActivate();
                        }
                    }
                }
            }
        }
    }
}
