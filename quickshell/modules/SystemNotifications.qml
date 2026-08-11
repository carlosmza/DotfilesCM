import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
import "../components"

ShellRoot {
    id: root

    readonly property bool hasBattery: UPower.displayDevice !== null
    readonly property real batteryPercentage: Math.max(0, Math.min(100, UPower.displayDevice?.percentage * 100 || 0))
    readonly property bool batteryCharging: UPower.onBattery === false
    property bool batteryLowNotified: false
    property bool batteryChargingNotified: false
    property bool batteryFullNotified: false
    property string notificationIcon: ""
    property string notificationLabel: ""
    property int notificationValue: -1

    Component.onCompleted: updateBatteryNotificationState()
    onHasBatteryChanged: updateBatteryNotificationState()
    onBatteryPercentageChanged: updateBatteryNotificationState()
    onBatteryChargingChanged: updateBatteryNotificationState()

    function showNotification(icon, label, value) {
        root.notificationIcon = icon
        root.notificationLabel = label
        root.notificationValue = value
        notification.show()
    }

    function updateBatteryNotificationState() {
        if (!root.hasBattery)
            return

        var percentage = Math.round(root.batteryPercentage)

        if (percentage < 25 && !root.batteryCharging) {
            if (!root.batteryLowNotified) {
                root.showNotification("󰂃", "low", percentage)
                root.batteryLowNotified = true
            }
        } else if (percentage >= 25 || root.batteryCharging) {
            root.batteryLowNotified = false
        }

        if (percentage >= 100) {
            if (!root.batteryFullNotified) {
                root.showNotification("󰁹", "full", percentage)
                root.batteryFullNotified = true
            }
        } else {
            root.batteryFullNotified = false
        }

        if (root.batteryCharging && percentage < 100) {
            if (!root.batteryChargingNotified) {
                root.showNotification("󰢝", "charging", percentage)
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
        implicitWidth: 160
        implicitHeight: 36
        visible: notification.showing || notification.opacity > 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: -1

        Notification {
            id: notification
            anchors.fill: parent
            icon: root.notificationIcon
            label: root.notificationLabel
            value: root.notificationValue
            duration: 4000
        }
    }
}
