import QtQuick
import Quickshell.Services.Notifications
import Quickshell

Scope{
    id: notificationData

    property Notification notification: null
    property bool triggerClose: false

    property string seqId: ""
    property string notifId: String(notification.id || "")

    property string summary: notification.summary || ""
    property string body: notification.body || ""
    property string appIcon: notification.appIcon || ""
    property string appName: notification.appName || ""
    property string image: notification.image || ""
    property var actions: notification.actions.map(function (a) {
            return {
                identifier: a.identifier,
                text: a.text
            };
        });
    property int urgency: notification.urgency
    property real expireTimeout: notification.expireTimeout > 0 ? notification.expireTimeout : defaultTimeout
    property int rowNums: 11 + (actions.length > 0 ? 2 : 0)
    property int cardHeight: rowNums * 15
    property int yPos: 800
    property bool hovered: false
    readonly property bool timerPaused: notificationData.triggerClose || notificationData.hovered
    readonly property int defaultTimeout: 5000  
    readonly property Connections _conn: Connections {
        target: notificationData.notification

        function onClosed(): void {
            if (notificationData.triggerClose)
                return;
            notificationData.triggerClose = true;
            Qt.callLater(function () {
                NotificationService._remove(notificationData);
                notificationData.destroy();
            });
        }

        function onSummaryChanged(): void {
            if (notificationData.notification)
                notificationData.summary = notificationData.notification.summary || "";
        }
        function onBodyChanged(): void {
            if (notificationData.notification)
                notificationData.body = notificationData.notification.body || "";
        }
        function onAppIconChanged(): void {
            if (notificationData.notification)
                notificationData.appIcon = notificationData.notification.appIcon || "";
        }
        function onAppNameChanged(): void {
            if (notificationData.notification)
                notificationData.appName = notificationData.notification.appName || "";
        }
        function onImageChanged(): void {
            if (notificationData.notification)
                notificationData.image = notificationData.notification.image || "";
        }
        function onUrgencyChanged(): void {
            if (notificationData.notification)
                notificationData.urgency = notificationData.notification.urgency;
        }
        function onExpireTimeoutChanged(): void {
            if (notificationData.notification)
                notificationData.expireTimeout = notificationData.notification.expireTimeout;
        }
        function onActionsChanged(): void {
            if (!notificationData.notification)
                return;
            notificationData.actions = notificationData.notification.actions.map(function (a) {
                return {
                    identifier: a.identifier,
                    text: a.text
                };
            });
        }
    }
	property int timerValue: expireTimeout
	property var timer: SequentialAnimation {
		id: timer
		paused: running && timerPaused
		NumberAnimation {
			target: notificationData
			property: "timerValue"
			to: 0
			duration: notificationData.expireTimeout
		}
		ScriptAction{
			script: notificationData.dismiss()
		}
	}
    function dismiss(): void {
        triggerClose = true;
    }
    function completeDismiss(): void {
        Qt.callLater(function () {
            NotificationService._remove(notificationData);
            if (notification)
                try {
                    notification.completeDismiss();
                } catch (e) {}
            destroy();
        });
    }

    function invokeAction(identifier): void {
        if (!identifier || triggerClose)
            return;
        triggerClose = true;
        if (notification) {
            const action = notification.actions.find(function (a) {
                return a.identifier === identifier;
            });
            if (action)
                try {
                    action.invoke();
                } catch (e) {}
        }
        Qt.callLater(function () {
            NotificationService._remove(notificationData);
            destroy();
        });
    }
}
