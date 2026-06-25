import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../common"
import "../../services"
import "."

Scope {
    id: overviewScope

	QtObject {
		id: overviewActions

		function moveSelectionLinear(deltaIndex) {
			const workspacesPerGroup = Config.options.overview.rows * Config.options.overview.columns;
			const currentId = Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1;
			const useWorkspaceMap = Config.options.overview.useWorkspaceMap;
			const workspaceMap = Config.options.overview.workspaceMap ?? [];
			const focusedMonitorId = Hyprland.focusedMonitor?.id ?? root.monitor?.id ?? 0;
			const workspaceOffset = useWorkspaceMap ? Number(workspaceMap[focusedMonitorId] ?? 0) : 0;
			const currentGroup = Math.floor((currentId - workspaceOffset - 1) / workspacesPerGroup);
			const minWorkspaceId = currentGroup * workspacesPerGroup + 1 + workspaceOffset;

			const rows = Config.options.overview.rows;
			const columns = Config.options.overview.columns;
			const reverseColumns = Config.options.overview.orderRightLeft;
			const reverseRows = Config.options.overview.orderBottomUp;

			const clampedIndex = Math.max(0, Math.min(workspacesPerGroup - 1, currentId - minWorkspaceId));
			const currentNormalRow = Math.floor(clampedIndex / columns);
			const currentNormalColumn = clampedIndex % columns;

			function toVisualRow(normalRow) {
				return reverseRows ? (rows - normalRow - 1) : normalRow;
			}

			function toVisualColumn(normalColumn) {
				return reverseColumns ? (columns - normalColumn - 1) : normalColumn;
			}

			function toNormalRow(visualRow) {
				return reverseRows ? (rows - visualRow - 1) : visualRow;
			}

			function toNormalColumn(visualColumn) {
				return reverseColumns ? (columns - visualColumn - 1) : visualColumn;
			}

			const total = rows * columns;
			const currentVisualIndex = toVisualRow(currentNormalRow) * columns + toVisualColumn(currentNormalColumn);
			const targetVisualIndex = ((currentVisualIndex + deltaIndex) % total + total) % total;
			const targetVisualRow = Math.floor(targetVisualIndex / columns);
			const targetVisualColumn = targetVisualIndex % columns;
			const targetNormalRow = toNormalRow(targetVisualRow);
			const targetNormalColumn = toNormalColumn(targetVisualColumn);
			const targetId = minWorkspaceId + targetNormalRow * columns + targetNormalColumn;

			
			Hyprland.dispatch(`hl.dsp.focus({workspace = '${targetId}'})`);
		}

		function nextColumn() {
			moveSelectionBy(0, 1);
		}
	}

    Variants {
        id: overviewVariants
        model: Quickshell.screens
        PanelWindow {
            id: root
            required property var modelData
            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)
            property bool blurEnabled: Config.options.overview.effects.enableBlur
            property bool backdropEnabled: Config.options.overview.effects.enableBackdrop
            property real backdropOpacity: Math.max(0, Math.min(1, Config.options.overview.effects.backdropOpacity))
            property bool closeOnFocusLoss: Config.options.overview.closeOnFocusLoss ?? true
            screen: modelData
            visible: GlobalStates.overviewOpen
            
            WlrLayershell.namespace: blurEnabled ? "quickshell:overview-blur" : "quickshell:overview"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                property bool canBeActive: root.monitorIsFocused
                active: false
                onCleared: () => {
                    // Only the monitor that owns the grab may close the overview
                    if (root.closeOnFocusLoss && !active && canBeActive)
                        GlobalStates.overviewOpen = false;
                }
            }

            Connections {
                target: GlobalStates
                function onOverviewOpenChanged() {
                    if (GlobalStates.overviewOpen) {
                        delayedGrabTimer.start();
                    }
                }
            }

            // Re-evaluate grab ownership when focused monitor changes
            Connections {
                target: Hyprland
                function onFocusedMonitorChanged() {
                    if (!GlobalStates.overviewOpen)
                        return;
                    // Transfer the grab to the newly focused monitor
                    if (root.monitorIsFocused && !grab.active) {
                        grab.active = true;
                    } else if (!root.monitorIsFocused && grab.active) {
                        grab.active = false;
                    }
                }
            }

            Timer {
                id: delayedGrabTimer
                interval: Config.options.hacks.arbitraryRaceConditionDelay
                repeat: false
                onTriggered: {
                    if (!grab.canBeActive)
                        return;
                    grab.active = GlobalStates.overviewOpen;
                }
            }

            // Keep the layershell surface full-screen so backdrop/blur are not constrained by content size.
            implicitWidth: screen.width
            implicitHeight: screen.height

            

            Item {
                id: keyHandler
                anchors.fill: parent
                visible: GlobalStates.overviewOpen
                focus: GlobalStates.overviewOpen
                z: 0

                Rectangle {
                    id: backdropLayer
                    anchors.fill: parent
                    visible: root.backdropEnabled
                    color: "#000000"
                    opacity: root.backdropOpacity
                    z: 0
                }

                MouseArea {
                    id: outsideClickCatcher
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    enabled: root.closeOnFocusLoss && GlobalStates.overviewOpen
                    z: 0
                    onPressed: mouse => {
                        GlobalStates.overviewOpen = false;
                        mouse.accepted = true;
                    }
                }
                Keys.onReleased: event => {
                    if (event.key === Qt.Key_Alt) {
                        GlobalStates.overviewOpen = false;
                        event.accepted = true;
                    }
                }
			}

			ColumnLayout {
				id: columnLayout
				visible: GlobalStates.overviewOpen
				z: 1
				anchors {
					horizontalCenter: parent.horizontalCenter
					top: parent.top
					topMargin: Config.options.position.topMargin
				}

				Loader {
					id: overviewLoader
					active: Config?.options.overview.enable ?? true
					sourceComponent: OverviewWidget {
						panelWindow: root
						visible: true
					}
				}
			}
        }
    }

    IpcHandler {
        target: "overview"

        property bool openState: GlobalStates.overviewOpen

        function toggle() {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
        }
        function close() {
            GlobalStates.overviewOpen = false;
        }
        function open_forward() {
            GlobalStates.overviewOpen = true;
			overviewActions.moveSelectionLinear(1);
        }
		function open_backward() {
            GlobalStates.overviewOpen = true;
			overviewActions.moveSelectionLinear(-1);
        }
    }
}
