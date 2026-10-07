import QtQuick
import QtQuick.Studio.Components
import QtQuick.Controls.Fusion
import Qt5Compat.GraphicalEffects

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../config/"

Scope {
    id: root
    property bool shouldShowStart: false
    property var arcsList: {
        let val = [];
        for (let i = 0; i < Arcs.beginList.length; i++) {
            val.push({
                begin: Arcs.beginList[i],
                end: Arcs.endList[i],
                radius: Arcs.radiusList[i],
                strokeWidth: Arcs.strokeWidthList[i]
            });
        }
        return val;
    }
    IpcHandler {
        target: "start"
        function toggle() {
            root.shouldShowStart = !root.shouldShowStart;
        }
    }
    LazyLoader {
        active: root.shouldShowStart
        PanelWindow {
            anchors {
                top: true
                left: true
                bottom: true
                right: true
            }
            contentItem {
                Keys.onPressed: event => {
                    if (event.key == Qt.Key_Return) {
                        filteredEntries[(entryIcons.selectedIndex % entryIcons.numItems) % entryIcons.visibleItems].execute();
                        root.shouldShowStart = false;
                        event.accepted = true;
                    } else if (event.key >= 65 && event.key <= 90) {
                        filter += event.text.toUpperCase();
                        entryIcons.selectedIndex = 0;
                        event.accepted = true;
                    } else if (event.key == Qt.Key_Backspace) {
                        filter = filter.slice(0, -1);
                        entryIcons.selectedIndex = 0;
                        event.accepted = true;
                    } else if (event.key == Qt.Key_Right) {
                        entryIcons.selectedIndex -= 1;
                        event.accepted = true;
                    } else if (event.key == Qt.Key_Left) {
                        entryIcons.selectedIndex += 1;
                        event.accepted = true;
                    } else if (event.key == Qt.Key_Escape) {
                        root.shouldShowStart = false;
                        event.accepted = true;
                    }
                }
            }
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "quickshell-start"
            property string filter: ""
            property var filteredEntries: DesktopEntries.applications.values.filter(entry => filter == "" || entry.id.toUpperCase().includes(filter) || entry.startupClass.toUpperCase().includes(filter) || entry.name.toUpperCase().includes(filter))
            color: "transparent"
            Item {
                id: circle
                anchors.fill: parent
                visible: false
                Rectangle {
                    anchors.centerIn: parent
                    width: 500
                    height: 500
                    radius: width / 2
                    color: Theme.accentBlue
                }
            }

            Item {
                id: arcs
                visible: false
                anchors.fill: parent
                ArcItem {
                    visible: true
                    anchors.centerIn: parent
                    width: 180
                    height: width
                    fillColor: "#00ffffff"
                    strokeColor: "red"
                    begin: 0
                    end: 360
                    strokeWidth: width / 2
                }
                ArcItem {
                    anchors.centerIn: parent
                    width: 300
                    height: width
                    fillColor: "#00ffffff"
                    begin: 0
                    end: 360
                    strokeWidth: 10
                }
                Repeater {
                    model: arcsList
                    delegate: ArcItem {
                        required property var modelData
                        property int time: (Math.random() + 1) * 5000
                        property real rotation: 0.0
                        NumberAnimation on rotation {
                            from: 0.0
                            to: 360.0
                            duration: time
                            loops: Animation.Infinite
                        }
                        anchors.centerIn: parent
                        width: modelData.radius
                        height: width
                        fillColor: "#00ffffff"
                        begin: modelData.begin + rotation
                        end: modelData.end + rotation
                        strokeWidth: modelData.strokeWidth
                    }
                }
            }
            OpacityMask {
                anchors.fill: parent
                scale: 3.0
                Component.onCompleted: scale = 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutQuint
                    }
                }
                maskSource: arcs
                source: circle
                invert: true
            }
            Item {
                id: entryIcons
                anchors.centerIn: parent
                property int size: 360
                width: size
                height: size
                property int numItems: 12
                property int selectedIndex: 0
                property int visibleItems: numItems
                focus: true
                Repeater {
                    model: ScriptModel {
                        values: filteredEntries.slice(0, entryIcons.numItems)
                        onValuesChanged: entryIcons.visibleItems = values.length
                    }
                    delegate: TextItem {
                        required property int index
                        property int actualIndex: entryIcons.visibleItems == 12 ? index - entryIcons.selectedIndex : (index - entryIcons.selectedIndex) % entryIcons.visibleItems
                        required property var modelData
                        property real angle: -Math.PI / 2 - Math.PI * 2 * actualIndex / entryIcons.numItems
                        Behavior on angle {
                            NumberAnimation {
                                duration: 150
                            }
                        }
                        x: entryIcons.size / 2 + Math.round(entryIcons.size / 2 * Math.cos(angle)) - implicitWidth / 2
                        y: entryIcons.size / 2 + Math.round(entryIcons.size / 2 * Math.sin(angle)) - implicitHeight / 2
                        text: Icons.get(modelData.id) ?? Icons.get(modelData.startupClass) ?? Icons.get(modelData.name) ?? "x"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Theme.fontIcon
                        font.pixelSize: actualIndex % entryIcons.numItems == 0 ? 60 : 35
                        Behavior on font.pixelSize {
                            NumberAnimation {
                                duration: 150
                            }
                        }
                        opacity: 0.0
                        NumberAnimation on opacity {
                            from: 0.0
                            to: 1.0
                            duration: 200
                            running: true
                        }
                        fillColor: Theme.bgBase
                        strokeColor: Theme.accentYellow
                        strokeWidth: 1
                    }
                }
            }
        }
    }
}
