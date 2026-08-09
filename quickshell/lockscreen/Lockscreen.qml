import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../config"

ShellRoot {
	id: root
	
	LockContext {
		id: lockContext

		Timer{
			id: unlockTimer
			interval: 200
			running: false
			onTriggered: lock.locked = false
		}
		onUnlocked: {
			root.shouldShowUnlockscreen = true
			unlockTimer.restart()
		}
	}
	property bool shouldShowLockscreen: false
	property bool shouldShowUnlockscreen: false
	property int screens: Quickshell.screens.length
	
	IpcHandler{
		target: "lockscreen"
		function lock(){
			root.shouldShowLockscreen = true
		}
		function postsleep(){
			lock.locked = true
			lockContext.restart()
		}
	}
	Variants{
		model: Quickshell.screens
		delegate: Item {
			id: root
			property var modelData
			
			LazyLoader {
				active: shouldShowLockscreen
				IntroLockscreen{
					screen: modelData
					Timer{
						id: timer
						interval: 100
						running: false
						onTriggered: shouldShowLockscreen = false
					}
					onLocked: {
						lock.locked = true
						lockContext.restart()
						timer.restart()
					}
					
				}
			}
			LazyLoader {
				active: shouldShowUnlockscreen
				Unlockscreen{
					screen: modelData
					onUnlocked: shouldShowUnlockscreen = false
				}
			}
		}
	}
	WlSessionLock {
		id: lock
		locked: false

		surface: WlSessionLockSurface {
			color: Theme.bgBase
			Loader {
				active: parent.width > 0 && parent.height > 0
				anchors.fill: parent
				sourceComponent: LockSurface {
					id: lockSurface
					anchors.fill: parent
					context: lockContext
					suspendable: screens == 1
				}
			}
		}
	}
}