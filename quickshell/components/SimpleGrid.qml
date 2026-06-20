import QtQuick

Item {
    id: root

    property int columns: 3
    property int rows: 3

    property real cellWidth: width / columns
    property real cellHeight: height / rows

    default property alias content: root.data
}