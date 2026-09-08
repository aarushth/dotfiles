import QtQuick
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent
    default property alias content: menuColumn.data
    function entries() {
        return menuColumn.children.filter(item => typeof item.isSeparator !== "undefined" && !item.isSeparator && item.hoverEnabled);
    }
    onMenuLengthChanged: selectByDefault()
    function selectByDefault() {
        const list = entries();
        if (list.length === 0) {
            selectedIndex = -1;
            return;
        }
        list.forEach(item => item.selected = false);
        selectedIndex = list.length - 1;
        list[selectedIndex].selected = true;
    }
    property int menuLength: entries().length
    property int selectedIndex: menuLength - 1
    signal dismiss
    implicitWidth: menuColumn.implicitWidth
    implicitHeight: menuColumn.implicitHeight
    Keys.onPressed: event => {
        if (event.key == Qt.Key_Down || event.key == Qt.Key_S) {
            moveDown();
        } else if (event.key == Qt.Key_Up || event.key == Qt.Key_W) {
            moveUp();
        } else if (event.key == Qt.Key_Return) {
            entries()[selectedIndex].clicked();
            root.dismiss();
        } else {
            root.dismiss();
        }
    }
    function moveUp() {
        entries()[selectedIndex].selected = false;
        selectedIndex = ((selectedIndex - 1) % menuLength + menuLength) % menuLength;
        entries()[selectedIndex].selected = true;
        console.warn(selectedIndex, entries().map(entry => entry.text));
    }
    function moveDown() {
        entries()[selectedIndex].selected = false;
        selectedIndex = (selectedIndex + 1) % menuLength;
        entries()[selectedIndex].selected = true;
    }
    focus: true
    ColumnLayout {
        id: menuColumn
        anchors.fill: parent
        spacing: 0
    }
}
