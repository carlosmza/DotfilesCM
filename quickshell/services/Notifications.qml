// Notifications.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property var toasts: []
    property bool dnd: false

    readonly property int maxToasts: 10
    property int _nextId: 1

    function mostrar(icon, label, value, duration) {
        root._push({
            id: root._nextId++,
            icon: icon,
            label: label,
            value: typeof value === "number" ? value : -1,
            duration: typeof duration === "number" && duration >= 0 ? duration : 0,
            summary: "",
            body: "",
            appName: "",
            appIcon: "",
            urgency: NotificationUrgency.Normal,
            notif: null,
            isCustom: true
        })
    }

    function addSystem(notif) {
        if (root.dnd && notif.urgency !== NotificationUrgency.Critical)
            return

        var duration = 4000
        if (notif.urgency === NotificationUrgency.Critical)
            duration = 0
        else if (notif.urgency === NotificationUrgency.Low)
            duration = 4000

        root._push({
            id: root._nextId++,
            icon: "",
            label: notif.summary,
            value: -1,
            duration: duration,
            summary: notif.summary,
            body: notif.body,
            appName: notif.appName,
            appIcon: notif.appIcon,
            urgency: notif.urgency,
            notif: notif,
            isCustom: false
        })
    }

    function _push(toast) {
        var capped = [toast, ...root.toasts].slice(0, root.maxToasts)
        root.toasts = capped
    }

    function dismiss(id) {
        var kept = []
        for (var i = 0; i < root.toasts.length; i++) {
            var t = root.toasts[i]
            if (t.id === id) {
                if (t.notif)
                    t.notif.dismiss()
            } else {
                kept.push(t)
            }
        }
        root.toasts = kept
    }

    function dismissAll() {
        for (var i = 0; i < root.toasts.length; i++) {
            var t = root.toasts[i]
            if (t.notif)
                t.notif.dismiss()
        }
        root.toasts = []
    }

    function toggleDnd() {
        root.dnd = !root.dnd
    }
}