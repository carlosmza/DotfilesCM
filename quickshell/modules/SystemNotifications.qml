import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
import qs.services
import "../components"

ShellRoot {
    id: root

    readonly property int maxVisible: 6
    readonly property int toastWidth: 320

    readonly property bool hasBattery: UPower.displayDevice !== null
    readonly property real batteryPercentage: Math.max(0, Math.min(100, UPower.displayDevice?.percentage * 100 || 0))
    readonly property bool batteryCharging: UPower.onBattery === false
    property bool batteryLowNotified: false
    property bool batteryChargingNotified: false
    property bool batteryFullNotified: false

    Component.onCompleted: updateBatteryNotificationState()
    onHasBatteryChanged: updateBatteryNotificationState()
    onBatteryPercentageChanged: updateBatteryNotificationState()
    onBatteryChargingChanged: updateBatteryNotificationState()

    function updateBatteryNotificationState() {
        if (!root.hasBattery)
            return

        var percentage = Math.round(root.batteryPercentage)

        if (percentage < 25 && !root.batteryCharging) {
            if (!root.batteryLowNotified) {
                Notifications.mostrar("󰂃", "low", percentage, 4000)
                root.batteryLowNotified = true
            }
        } else if (percentage >= 25 || root.batteryCharging) {
            root.batteryLowNotified = false
        }

        if (percentage >= 100) {
            if (!root.batteryFullNotified) {
                Notifications.mostrar("󰁹", "full", percentage, 4000)
                root.batteryFullNotified = true
            }
        } else {
            root.batteryFullNotified = false
        }

        if (root.batteryCharging && percentage < 100) {
            if (!root.batteryChargingNotified) {
                Notifications.mostrar("󰢝", "charging", percentage, 3000)
                root.batteryChargingNotified = true
            }
        } else {
            root.batteryChargingNotified = false
        }
    }

    PanelWindow {
        id: notificationPanel
        anchors { top: true }
        margins { top: 100 }
        color: "transparent"
        implicitWidth: root.toastWidth
        implicitHeight: toastColumn.implicitHeight
        visible: Notifications.toasts.length > 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: -1

        Column {
            id: toastColumn
            width: parent.width
            spacing: 8

            Repeater {
                model: Notifications.toasts.slice(0, root.maxVisible)

                Notification {
                    id: toast
                    width: parent.width
                    icon: modelData.icon
                    label: modelData.label
                    value: modelData.value
                    summary: modelData.summary
                    body: modelData.body
                    appName: modelData.appName
                    appIcon: modelData.appIcon
                    urgency: modelData.urgency
                    duration: modelData.duration

                    Component.onCompleted: toast.show()
                    onExpired: Notifications.dismiss(modelData.id)
                }
            }
        }
    }
}