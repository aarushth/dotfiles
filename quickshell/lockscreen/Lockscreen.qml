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
	}

	Timer {
		id: resetTimer
		interval: 1000
		repeat: false
		onTriggered: {
			invert = false
			if (lockContext.message === "Place your right index finger on the fingerprint reader"){
				displayText = "SCAN 󰈷 FINGERPRINT"
			}else if(lockContext.message === "Password: "){
				displayText = ""
			}else{
				lockContext.restart()
				invert = true
				displayText = "SYSTEM LOCKED"
			}
		}
	}
	property bool invert: false
	property string displayText: "SYSTEM LOCKED"

	Connections {
		target: lockContext

		function onMessageChanged() {
			switch (lockContext.message) {
				case "Failed to match fingerprint":
					invert = true
					resetTimer.restart()
					displayText = "ACCESS DENIED"
					break

				case "Place your right index finger on the fingerprint reader":
					if (!resetTimer.running){
						invert = false
						displayText = "SCAN 󰈷 FINGERPRINT"
					}
					break
				case "Password: ":
					if (!resetTimer.running){
						invert = false
						displayText = ""
					}
					break

				default:
					if (resetTimer.running && !lockContext.responseRequired){
						displayText = "ACCESS DENIED"
					}
			}
		}
		function onFailure(){
			displayText = "ACCESS DENIED"
			resetTimer.restart()
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
			Lockevents.onIntroCompleted()
		}
	}
	property int timer: 0
	property int timeout: 60
	NumberAnimation{
		id: countdown
		running: true
		from: timeout
		to: 0
		duration: timeout*1000
		target: root
		property: "timer"
	}
	Timer {
        id: suspendTimer
        interval: timeout * 1000
        running: lock.locked
		repeat: true
        onTriggered: {
			suspend.startDetached()
			countdown.restart()
			lockContext.restart()
        }
    }

	Connections{
		target: Lockevents
		function onCancelCompleted() {
			root.shouldShowLockscreen = false
		}
		function onIntroCompleted() {
			lock.locked = true
			lockContext.restart()
			Lockevents.resetTimer()
			Qt.callLater(() => {root.shouldShowLockscreen = false})
		}

		function onResetTimer() {
			suspendTimer.restart()	
			countdown.restart()
		}
		function onUnlocked(){
			root.shouldShowUnlockscreen = true
		}
		function onUnlockScreenUp(){
            lock.locked = false
            suspendTimer.stop()
        }
	}
	readonly property var suspend: Process {
		command: ["sh", "-c", "systemctl suspend"]
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
					invert: root.invert
					displayText: root.displayText
					timer: root.timer
					resetTimerRunning: resetTimer.running
				}
			}
		}
	}
}
