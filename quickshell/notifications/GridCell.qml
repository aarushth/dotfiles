import QtQuick

Item {
    id: root

    property int gridColumn: 0
    property int gridRow: 0

    property int gridColumnSpan: 1
    property int gridRowSpan: 1

    x: gridColumn * parent.cellWidth
    y: gridRow * parent.cellHeight

    width: gridColumnSpan * parent.cellWidth
    height: gridRowSpan * parent.cellHeight

    default property alias content: contentItem.data

    Item {
        id: contentItem
        anchors.fill: parent
    }
}