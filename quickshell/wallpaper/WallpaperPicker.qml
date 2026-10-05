import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "../config"

Item {
    id: root
    property bool shouldShowPicker: false
    readonly property real itemWidth: 400
    readonly property real itemHeight: 420
    readonly property real spacing: 10
    readonly property real skewFactor: 0.35
    property real scrollThreshold: 150
    property int scrollAccum: 0
    property bool closing: false

    IpcHandler {
        target: "wallpaper"
        function open() {
            if (!root.shouldShowPicker) {
                closing = false;
                root.shouldShowPicker = true;
            }
        }
    }
    Timer {
        id: closeTimer
        running: false
        interval: 400
        onTriggered: {
            root.shouldShowPicker = false;
        }
    }
    property string url: ""
    property int index: 0
    FolderListModel {
        id: srcModel
        folder: "file://" + root.srcDir
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif"]
        showDirs: false
        onStatusChanged: {
            if (status == FolderListModel.Ready) {
                root.index = Math.floor(Math.random() * srcModel.count);
                root.url = srcModel.get(root.index, "filePath");
                root.changeWallpaper();
            }
        }
    }
    function applyWallpaper(filePath) {
        Quickshell.execDetached(["hyprctl", "eval", "SwitchToWallpaperWs()"]);
        root.url = filePath;
        switchAnim.running = true;
    }
    function changeWallpaper() {
        Quickshell.execDetached(["awww", "img", url, "--transition-type", "none"]);
    }
    readonly property string srcDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"

    property bool animating: false
    property bool gridVisible: false
    SequentialAnimation {
        id: switchAnim
        running: false
        PauseAnimation {
            duration: 200
        }
        ScriptAction {
            script: {
                closing = true;
                gridVisible = true;
                animating = true;
            }
        }
        PauseAnimation {
            duration: 1000
        }
        ScriptAction {
            script: root.changeWallpaper()
        }
        PauseAnimation {
            duration: 300
        }
        ScriptAction {
            script: animating = false
        }
        PauseAnimation {
            duration: 1000
        }
        ScriptAction {
            script: {
                gridVisible = false;
                shouldShowPicker = false;
            }
        }
    }
    LazyLoader {
        active: root.shouldShowPicker
        Window {
            id: window
            title: "quickshell-wallpaper-picker"
            color: "transparent"
            onVisibleChanged: view.currentIndex = root.index
            visible: true
            onClosing: close => {
                close.accepted = false;
                root.closing = true;
                closeTimer.start();
            }
            ListView {
                id: view
                model: srcModel
                width: Screen.width * 1.5
                height: root.itemHeight
                anchors.centerIn: parent
                orientation: ListView.Horizontal
                keyNavigationWraps: true

                highlightRangeMode: ListView.StrictlyEnforceRange

                readonly property real currentDelegateWidth: (root.itemWidth * 1.5) + extraSkew
                readonly property real skewOffset: (root.skewFactor * root.itemHeight) / 2
                preferredHighlightBegin: ((width - currentDelegateWidth) / 2) - skewOffset
                preferredHighlightEnd: preferredHighlightBegin + currentDelegateWidth
                property int extraSkew: root.itemWidth * skewFactor * 2 + root.spacing * 2
                highlightMoveDuration: 500
                focus: true
                spacing: -extraSkew + (root.spacing * 2)
                Keys.onPressed: event => {
                    if (event.key == Qt.Key_Return) {
                        root.index = view.currentIndex;
                        root.applyWallpaper(srcModel.get(view.currentIndex, "filePath"));
                        event.accepted = true;
                    } else if (event.key === Qt.Key_H) {
                        view.decrementCurrentIndex();
                        event.accepted = true; // Stop event propagation
                    } else if (event.key === Qt.Key_L) {
                        view.incrementCurrentIndex();
                        event.accepted = true;
                    }
                }
                WheelHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    orientation: Qt.Horizontal

                    onWheel: wheel => {
                        if (root.isItemAnimating) {
                            event.accepted = true;
                            return;
                        }
                        let dx = wheel.pixelDelta.x;
                        let dy = wheel.pixelDelta.y;
                        let delta = Math.abs(dx) > Math.abs(dy) ? dx : dy;

                        scrollAccum += delta;
                        if (Math.abs(scrollAccum) >= root.scrollThreshold) {
                            view.currentIndex += scrollAccum > 0 ? -1 : 1;
                            scrollAccum = 0;
                        }

                        wheel.accepted = true;
                    }
                }

                delegate: Item {
                    id: delegateRoot
                    readonly property bool isVisuallyEnlarged: ListView.isCurrentItem
                    property real targetWidth: isVisuallyEnlarged ? root.itemWidth * 1.5 : root.itemWidth * 0.5
                    readonly property real targetHeight: root.itemHeight

                    width: targetWidth + view.extraSkew
                    height: targetHeight
                    clip: true
                    anchors.leftMargin: 20
                    Behavior on targetWidth {
                        enabled: true
                        NumberAnimation {
                            duration: 500
                            easing.type: Easing.InOutQuad
                        }
                    }
                    Item {
                        id: skewMask
                        anchors.centerIn: parent

                        width: parent.width

                        height: targetHeight
                        property bool startAnimation: false

                        Rectangle {
                            anchors.centerIn: parent
                            width: targetWidth
                            height: root.closing ? 0 : (parent.startAnimation ? targetHeight : 0)
                            Behavior on height {
                                NumberAnimation {
                                    duration: 200
                                }
                            }
                            visible: true

                            transform: Matrix4x4 {
                                property real s: root.skewFactor
                                matrix: Qt.matrix4x4(1, s, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (view.currentIndex != index) {
                                        view.currentIndex = index;
                                    } else {
                                        root.index = view.currentIndex;
                                        root.applyWallpaper(filePath);
                                    }
                                }
                            }
                        }
                    }
                    Item {
                        id: imageContainer
                        anchors.centerIn: parent
                        width: parent.width
                        height: targetHeight
                        visible: true
                        opacity: 0
                        Image {
                            id: image
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: -50
                            width: parent.width + view.extraSkew
                            height: root.itemHeight
                            fillMode: Image.PreserveAspectCrop
                            source: fileUrl
                            cache: false
                            visible: image.status == Image.Ready
                            asynchronous: true
                            onStatusChanged: {
                                if (image.status == Image.Ready) {
                                    skewMask.startAnimation = true;
                                } else {
                                    skewMask.startAnimation = false;
                                }
                            }
                        }
                    }
                    OpacityMask {
                        anchors.centerIn: parent
                        width: parent.width
                        height: targetHeight
                        maskSource: skewMask
                        source: imageContainer
                    }
                }
            }
        }
    }
    LazyLoader {
        id: loader
        active: switchAnim.running
        Item {

            Variants {
                model: Quickshell.screens
                delegate: PanelWindow {
                    id: gridWindow
                    property var modelData
                    screen: modelData
                    visible: root.gridVisible
                    property int boxSize: 20
                    property int colNums: screen.width / boxSize
                    property int rowNums: screen.height / boxSize
                    property int totalBoxes: colNums * rowNums
                    property int revealInd: root.animating ? totalBoxes : 0
                    Behavior on revealInd {
                        NumberAnimation {
                            duration: 800
                        }
                    }
                    property var gridRef: null

                    property var boxes: []
                    onTotalBoxesChanged: boxes = Boxes.getBoxes(totalBoxes, biasFunc, "wallpaper")
                    function biasFunc(index) {
                        let row = index / colNums;
                        return Math.max(rowNums - row, row) / rowNums;
                    }
                    WlrLayershell.layer: WlrLayer.Overlay
                    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                    WlrLayershell.namespace: "quickshell-lockscreen"
                    anchors {
                        top: true
                        bottom: true
                        left: true
                        right: true
                    }
                    color: "transparent"
                    Grid {
                        id: grid
                        anchors.fill: parent
                        columns: colNums
                        rows: rowNums
                        visible: true

                        Repeater {
                            model: totalBoxes

                            delegate: Rectangle {
                                width: boxSize
                                height: boxSize
                                property int idx: 100000
                                Component.onCompleted: idx = gridWindow.boxes[index]
                                color: Theme.accentPurple
                                opacity: (idx < gridWindow.revealInd) ? 1 : 0
                            }
                        }
                    }
                }
            }
        }
    }
}
