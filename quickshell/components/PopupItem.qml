import QtQuick
import QtQuick.Layouts
import "../config"

Rectangle {
    id: root
    property bool selected: false
    property bool emphasized: true
    property string text: ""
    property string icon: ""
    property bool hoverEnabled: true
    signal clicked
    property bool isSeparator: false
    implicitWidth: label.contentWidth + iconBox.width + 20
    height: isSeparator ? 1 : 25
    color: isSeparator ? Theme.textMuted : (actionHover.containsMouse ? Theme.bgButton : Theme.bgButtonHover)
    border.color: Theme.textSecondary
    border.width: selected ? 2 : 0
    RowLayout {
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 10
        }
        Image {
            id: iconBox
            source: root.icon
            fillMode: Image.PreserveAspectFit
            Layout.preferredWidth: 15
            Layout.preferredHeight: 15
            sourceSize: Qt.size(15, 15)
            visible: root.icon !== ""
            opacity: root.emphasized ? 1 : 0.4
        }
        Text {
            id: label

            color: root.emphasized ? Theme.textSecondary : Theme.textMuted
            text: root.text
            opacity: root.emphasized ? 1 : 0.4

            font.pixelSize: 12
            font.family: Theme.fontNormal
        }
    }
    MouseArea {
        id: actionHover
        anchors.fill: parent
        enabled: root.hoverEnabled
        hoverEnabled: root.hoverEnabled
        cursorShape: root.hoverEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
