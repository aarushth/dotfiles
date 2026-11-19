import QtQuick
import QtQuick.Studio.Components
import QtQuick.Controls.Fusion
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../config/"

Scope {
    id: root

    property bool shouldShowStart: false
    property int outerCircleRadius: 500
    property int iconCircleRadius: 360
    property int innerCircleRadius: 230
    IpcHandler {
        target: "start"
        function toggle() {
            root.shouldShowStart = !root.shouldShowStart;
        }
    }
    LazyLoader {
        active: root.shouldShowStart
        PanelWindow {
            id: panelRoot
            anchors {
                top: true
                left: true
                bottom: true
                right: true
            }
            contentItem {
                Keys.onPressed: event => {
                    if (event.key == Qt.Key_Return) {
                        let entry = filteredEntries[entryIcons.currentIndex];
                        if (entry)
                            entry.execute();
                        exitAnim.start();
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
            property int animDuration: 300
            property int arcsListLength: Arcs.beginList.length
            property var arcsList: {
                let val = [];
                for (let i = 0; i < arcsListLength; i++) {
                    val.push({
                        id: i,
                        begin: Arcs.beginList[i],
                        end: Arcs.endList[i],
                        radius: Arcs.radiusList[i],
                        strokeWidth: Arcs.strokeWidthList[i]
                    });
                }
                return val;
            }

            ParallelAnimation {
                id: exitAnim
                PropertyAnimation {
                    target: circle
                    property: "color"
                    to: Theme.accentYellow
                }
                PropertyAnimation {
                    target: coolParent
                    property: "rotation"
                    from: 0
                    to: -90
                    duration: animDuration
                }
                PropertyAnimation {
                    target: panelRoot
                    property: "arcsListLength"
                    to: 0
                    duration: animDuration
                }
                PropertyAnimation {
                    target: entryIcons
                    property: "visibleIndex"
                    to: 0
                    duration: animDuration
                    easing: Easing.InQuint
                }

                PropertyAnimation {
                    target: entryIcons
                    property: "visibleIndex"
                    to: 0
                    duration: animDuration
                }

                PropertyAnimation {
                    target: mainMask
                    property: "scale"
                    from: 1.0
                    to: 2.0
                    duration: animDuration
                    easing: Easing.InQuint
                }
                SequentialAnimation {
                    PauseAnimation {
                        duration: animDuration + 10
                    }
                    ScriptAction {
                        script: root.shouldShowStart = false
                    }
                }
            }
            Item {
                id: circleRoot
                anchors.fill: parent
                visible: false
                Rectangle {
                    id: circle
                    anchors.centerIn: parent
                    width: outerCircleRadius
                    height: outerCircleRadius
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
                    model: ScriptModel {
                        values: arcsList
                        objectProp: "id"
                    }
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
                id: arcsMask
                anchors.fill: parent
                maskSource: arcs
                source: circleRoot
                invert: true
                visible: false
            }
            OpacityMask {
                id: mainMask
                anchors.fill: parent
                source: arcsMask
                maskSource: coolMask
                invert: true
                visible: true
                scale: 3.0
                Component.onCompleted: introAnim.start()
                PropertyAnimation {
                    id: introAnim
                    target: mainMask
                    property: "scale"
                    to: 1.0
                    duration: 400
                    easing.type: Easing.OutQuint
                }
            }
            Item {
                id: entryIcons
                anchors.centerIn: parent
                property int size: iconCircleRadius
                width: size
                height: size
                property int numItems: 12
                property int visibleIndex: visibleItems
                onVisibleIndexChanged: console.warn(visibleIndex)
                property int selectedIndex: 0
                property int visibleItems: numItems
                property int currentIndex: visibleItems > 0 ? ((selectedIndex % visibleItems) + visibleItems) % visibleItems : -1
                focus: true
                Repeater {
                    model: ScriptModel {
                        values: filteredEntries.slice(0, entryIcons.numItems)
                        objectProp: "id"
                        onValuesChanged: entryIcons.visibleItems = values.length
                    }
                    delegate: TextItem {
                        required property int index
                        property int actualIndex: entryIcons.visibleItems == entryIcons.numItems ? index - entryIcons.selectedIndex : (index - entryIcons.selectedIndex) % entryIcons.visibleItems
                        property int ringIndex: ((actualIndex % entryIcons.visibleItems) + entryIcons.visibleItems) % entryIcons.visibleItems
                        visible: ringIndex == 0 || ringIndex < entryIcons.visibleIndex
                        required property var modelData
                        property real angle: -Math.PI / 2 - Math.PI * 2 * actualIndex / entryIcons.numItems
                        Behavior on angle {
                            NumberAnimation {
                                duration: 150
                            }
                        }
                        x: entryIcons.size / 2 + Math.round(entryIcons.size / 2 * Math.cos(angle)) - implicitWidth / 2
                        y: entryIcons.size / 2 + Math.round(entryIcons.size / 2 * Math.sin(angle)) - implicitHeight / 2
                        text: Icons.get(modelData.id, modelData.startupClass) ?? Icons.get(modelData.name, modelData.command.join()) ?? ""
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
            Item {
                id: coolParent
                anchors.fill: parent
                rotation: 0
                Item {
                    anchors.centerIn: parent
                    width: innerCircleRadius
                    height: innerCircleRadius
                    Image {
                        id: cool
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            right: parent.right
                            rightMargin: 10
                        }
                        fillMode: Image.PreserveAspectFit
                        source: "cool.svg"
                    }
                    Text {
                        text: filteredEntries[entryIcons.currentIndex]?.name ?? ""
                        rotation: 90
                        width: parent.height
                        height: implicitHeight
                        anchors {
                            verticalCenter: parent.verticalCenter
                            horizontalCenter: cool.left
                            horizontalCenterOffset: -height / 2
                        }
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 15
                        font.family: Theme.fontFancy
                        color: Theme.accentBlueLight
                    }
                }
                Item {
                    id: coolMask
                    anchors.fill: parent
                    visible: false
                    Shape {
                        id: trapezoidShape
                        rotation: coolParent.rotation
                        anchors.centerIn: parent
                        width: innerCircleRadius
                        height: innerCircleRadius + 65
                        ShapePath {
                            fillColor: "steelblue"
                            strokeColor: "black"
                            startX: 135
                            startY: 0
                            PathLine {
                                x: 215
                                y: 38
                            }
                            PathLine {
                                x: 215
                                y: innerCircleRadius + 30
                            }
                            PathLine {
                                x: 135
                                y: innerCircleRadius + 60
                            }
                            PathLine {
                                x: 135
                                y: 0
                            }
                        }
                    }
                }
            }
        }
    }
}
