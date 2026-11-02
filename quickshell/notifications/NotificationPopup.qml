import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "../config"

Scope {
    id: root
    property int boxSize: 12
    property int colNums: 24

    IpcHandler {
        target: "notifications"

        function dismiss_all() {
            NotificationService.dismissAll();
        }

        function dnd_toggle() {
            NotificationService.doNotDisturb = !NotificationService.doNotDisturb;
        }
    }

    Variants {
        id: variants
        model: Quickshell.screens
        delegate: PanelWindow {
            id: windowRoot
            required property var modelData
            screen: modelData
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "quickshell-notifications"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors {
                top: true
                right: true
                bottom: true
                left: true
            }
            margins {
                top: 10
                right: 10
            }
            color: "transparent"
            implicitWidth: root.colNums * root.boxSize
            implicitHeight: layout.implicitHeight

            Region {
                id: cardsRegion
                regions: {
                    notifRepeater.count;
                    return Array.from({
                        length: notifRepeater.count
                    }, (_, i) => notifRepeater.itemAt(i)).filter(c => c && c.shown).map(c => c.region);
                }
            }

            mask: cardsRegion
            BackgroundEffect.blurRegion: cardsRegion

            Column {
                id: layout
                spacing: 10
                anchors {
                    top: parent.top
                    right: parent.right
                }

                move: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 200
                    }
                }
                Repeater {
                    id: notifRepeater
                    model: ScriptModel {
                        values: NotificationService.notifications
                        objectProp: "seqId"
                    }

                    delegate: Item {
                        id: notifCard
                        required property NotificationData modelData
                        property NotificationData notificationData: modelData
                        property bool closing: false
                        property bool isImage: notificationData.image !== "" && notifImage.status === Image.Ready
                        property int rowNums: 11 + (notificationData.actions.length > 0 ? 2 : 0)
                        property int totalBoxes: rowNums * colNums
                        property int cardHeight: rowNums * root.boxSize
                        property int cardWidth: colNums * root.boxSize
                        property var boxes: Boxes.getBoxes(totalBoxes)
                        property color cardColor: notificationData.urgency === NotificationUrgency.Critical ? Theme.urgencyCritical : notificationData.urgency === NotificationUrgency.Low ? Theme.urgencyLow : Theme.urgencyNormal
                        readonly property bool shown: notifWindow.visible
                        readonly property Region region: Region {
                            item: notifWindow      // was: notifCard
                        }
                        Layout.rightMargin: cardHover.hovered ? 20 : 0
                        Connections {
                            target: notificationData
                            function onDismiss() {
                                closing = true;
                                entryAnim.start();
                            }
                        }
                        HoverHandler {
                            id: cardHover
                            onHoveredChanged: {
                                if (hovered) {
                                    if (notificationData.timer.running) {
                                        notificationData.timer.pause();
                                    }
                                } else {
                                    notificationData.timer.resume();
                                }
                            }
                            blocking: false
                        }

                        implicitWidth: notifCard.cardWidth + 20
                        implicitHeight: notifCard.cardHeight
                        Component.onCompleted: entryAnim.start()

                        Rectangle {
                            id: squares
                            z: 1
                            color: "transparent"
                            anchors {
                                top: parent.top
                                right: parent.right
                                rightMargin: cardHover.hovered ? 20 : 0
                                bottom: parent.bottom
                            }
                            width: notifCard.cardWidth

                            Item {
                                id: grid
                                anchors.fill: parent
                                property int revealInd: 0
                                property var entryAnim: SequentialAnimation {
                                    id: entryAnim
                                    running: false
                                    ScriptAction {
                                        script: {
                                            grid.revealInd = 0;
                                            squares.visible = true;
                                        }
                                    }
                                    NumberAnimation {
                                        target: grid
                                        property: "revealInd"
                                        from: 0
                                        to: boxes.length
                                        duration: 500
                                        running: false
                                    }
                                    PauseAnimation {
                                        duration: 100
                                    }
                                    ScriptAction {
                                        script: {
                                            notifWindow.visible = !notifWindow.visible;
                                        }
                                    }
                                    NumberAnimation {
                                        target: grid
                                        property: "revealInd"
                                        from: boxes.length
                                        to: 0
                                        duration: 500
                                        running: false
                                    }
                                    ScriptAction {
                                        script: {
                                            squares.visible = false;
                                            if (notificationData.urgency !== NotificationUrgency.Critical) {
                                                notificationData.timer.start();
                                            }
                                            if (notifCard.closing) {
                                                notifCard.notificationData.completeDismiss();
                                            }
                                        }
                                    }
                                }
                                GridLayout {
                                    columns: root.colNums
                                    columnSpacing: 0
                                    rowSpacing: 0
                                    Repeater {
                                        model: totalBoxes
                                        delegate: Rectangle {
                                            required property int index
                                            width: root.boxSize
                                            height: root.boxSize
                                            property int idx: notifCard.boxes[index]
                                            color: notifCard.cardColor
                                            opacity: (idx < grid.revealInd) ? 1 : 0
                                        }
                                    }
                                }
                            }
                        }
                        Rectangle {
                            id: notifWindow
                            z: 0
                            visible: false
                            color: "transparent"
                            anchors {
                                top: parent.top
                                right: parent.right
                                rightMargin: cardHover.hovered ? 20 : 0
                                bottom: parent.bottom
                            }
                            width: notifCard.cardWidth
                            Rectangle {
                                id: topBackground
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    right: parent.right
                                }
                                height: root.boxSize * 2
                                color: notifCard.cardColor
                            }
                            Rectangle {
                                id: blurCard
                                anchors {
                                    top: topBackground.bottom
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                color: Theme.bgBase
                                opacity: 0.6
                            }
                            Text {
                                id: icon
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                }
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                width: root.boxSize * 2
                                height: boxSize * 2
                                text: Icons.get(notifCard.notificationData.appName.toLowerCase()) ?? "󰂚"
                                color: Theme.textPrimary
                                font.pixelSize: 12
                                font.family: Theme.fontIcon
                            }
                            Rectangle {
                                id: divider
                                anchors {
                                    top: icon.top
                                    left: icon.right
                                    bottom: icon.bottom
                                }
                                width: 1
                                color: "black"
                            }
                            Text {
                                id: appName
                                anchors {
                                    top: divider.top
                                    bottom: divider.bottom
                                    left: divider.right
                                    right: parent.right
                                    leftMargin: 10
                                }
                                verticalAlignment: Text.AlignVCenter
                                font.capitalization: Font.Capitalize
                                text: notifCard.notificationData.summary || "Notification"
                                color: Theme.textPrimary
                                font.pixelSize: 12
                                font.family: Theme.fontNormal
                            }
                            Item {
                                anchors {
                                    top: appName.top
                                    bottom: appName.bottom
                                    right: parent.right
                                }
                                width: boxSize * 2
                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    text: "󰅖"
                                    color: Theme.textPrimary
                                    font.pixelSize: closeHover.containsMouse ? 15 : 10
                                    font.family: Theme.fontIcon
                                    Behavior on font.pixelSize {
                                        NumberAnimation {
                                            duration: 100
                                        }
                                    }
                                }

                                MouseArea {
                                    id: closeHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: notifCard.notificationData.dismiss()
                                }
                            }
                            Text {
                                id: title
                                anchors {
                                    top: appName.bottom
                                    left: parent.left
                                    right: parent.right
                                    leftMargin: boxSize
                                    rightMargin: boxSize
                                }
                                height: boxSize * 3
                                verticalAlignment: Text.AlignVCenter
                                text: notifCard.notificationData.appName
                                color: Theme.textSecondary
                                font.pixelSize: 18
                                font.family: Theme.fontTitle
                                font.styleName: "Black"
                                font.capitalization: Font.AllUppercase
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                visible: text !== ""
                            }
                            Rectangle {
                                anchors {
                                    top: title.bottom
                                    left: title.left
                                    right: title.right
                                }
                                height: 1
                                opacity: 0.1
                                color: Theme.textMuted
                            }
                            Text {
                                anchors {
                                    top: title.bottom
                                    left: parent.left
                                    topMargin: boxSize / 4
                                    leftMargin: boxSize
                                    rightMargin: boxSize
                                }
                                text: notifCard.notificationData.body
                                color: Theme.textMuted
                                height: boxSize * 4
                                width: (notifCard.colNums - (notifCard.isImage ? 6 : 2)) * boxSize
                                font.family: Theme.fontNormal
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                visible: text !== ""
                            }
                            Rectangle {
                                anchors {
                                    top: title.bottom
                                    right: parent.right
                                    rightMargin: boxSize
                                }
                                color: "transparent"
                                visible: notifCard.isImage
                                width: boxSize * 4
                                height: boxSize * 4
                                clip: true
                                Image {
                                    id: notifImage
                                    width: parent.width - 10
                                    height: parent.height - 10
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                    source: notifCard.notificationData.image
                                    fillMode: Image.PreserveAspectCrop
                                }
                            }
                            Item {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    bottom: actions.visible ? actions.top : parent.bottom
                                }
                                height: boxSize * 2
                                Rectangle {
                                    anchors.fill: parent
                                    color: Theme.textPrimary
                                }
                                Rectangle {
                                    id: progressBar
                                    height: parent.height
                                    width: parent.width * notificationData.timerValue / notificationData.expireTimeout
                                    visible: notifCard.notificationData.urgency !== NotificationUrgency.Critical
                                    radius: 1
                                    color: notifCard.cardColor
                                    opacity: 1
                                }
                                Rectangle {
                                    id: supIcon
                                    width: 14
                                    height: 14
                                    anchors {
                                        verticalCenter: progressBar.verticalCenter
                                        left: progressBar.left
                                        leftMargin: boxSize
                                    }
                                    color: Theme.bgBase
                                    border.color: Theme.textSecondary
                                    radius: 3
                                    Text {
                                        anchors.centerIn: parent
                                        width: parent.width
                                        height: parent.height

                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter

                                        color: Theme.textSecondary
                                        text: ""
                                        font.pixelSize: 6
                                        font.family: Theme.fontIcon
                                    }
                                }
                                Rectangle {
                                    id: xIcon
                                    width: 14
                                    height: 14
                                    anchors {
                                        verticalCenter: progressBar.verticalCenter
                                        left: supIcon.right
                                        leftMargin: boxSize / 4
                                    }
                                    color: Theme.bgBase
                                    border.color: Theme.textSecondary
                                    radius: 3
                                    Text {
                                        anchors.centerIn: parent
                                        width: parent.width
                                        height: parent.height

                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter

                                        color: Theme.textSecondary
                                        text: "󰅖"
                                        font.family: Theme.fontIcon
                                        font.pixelSize: 6
                                    }
                                }
                                Text {
                                    anchors {
                                        top: progressBar.top
                                        bottom: progressBar.bottom
                                        left: xIcon.right
                                        leftMargin: boxSize
                                    }
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: Theme.fontNormal
                                    color: Theme.textSecondary
                                    text: "Dismiss"
                                }
                            }
                            RowLayout {
                                id: actions
                                anchors {
                                    bottom: parent.bottom
                                    left: parent.left
                                    right: parent.right
                                }
                                height: boxSize * 2
                                uniformCellSizes: true
                                spacing: 0
                                visible: notifCard.notificationData.actions.length > 0
                                Repeater {
                                    model: notifCard.notificationData.actions
                                    Layout.preferredWidth: parent.width
                                    Layout.preferredHeight: parent.height
                                    Rectangle {
                                        id: actionBtn
                                        required property var modelData
                                        property var action: modelData
                                        required property int index
                                        Layout.preferredWidth: notifCard.cardWidth / notifCard.notificationData.actions.length
                                        Layout.preferredHeight: parent.height
                                        opacity: 0.6
                                        color: actionHover.containsMouse ? Theme.bgButto.hovered : Theme.bgButton
                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 100
                                            }
                                        }
                                        Text {
                                            id: actionText
                                            text: action.text || ""
                                            color: Theme.textSecondary
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignHCenter
                                            font.pixelSize: 11
                                            font.family: Theme.fontNormal
                                            width: parent.Layout.preferredWidth
                                            height: parent.Layout.preferredHeight
                                        }

                                        MouseArea {
                                            id: actionHover
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: notifCard.notificationData.invokeAction(action.identifier)
                                        }
                                        Rectangle {
                                            anchors {
                                                top: parent.top
                                                bottom: parent.bottom
                                                right: parent.right
                                            }
                                            color: "black"
                                            visible: parent.index + 1 < notifCard.notificationData.actions.length
                                            width: 1
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
}
