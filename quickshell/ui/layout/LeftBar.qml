import Quickshell
import Quickshell.Io
import QtQuick 2.15
import QtQuick.Layouts
import "../components"
import "../animations/"
import "../popups/"
import qs.config.theme

PanelWindow {
    id: root
    property int size: 32
    anchors {
        top: true
        left: true
        bottom: true
    }

    margins {
        left: 5
        top: 5
        bottom: 5
        right: 5
    }
    implicitWidth: 35
    color: "transparent"

    Rectangle {
        color: Colors.palette.base00
        anchors.fill: parent
        radius: 0
        clip: false   // ¡importante para que los popups se vean!

        Item {
            id: workspaces
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 40
            }
            Workspaces {
                anchors.centerIn: parent
            }
        }

        Item {
            id: windows
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 450
            }
            implicitWidth: root.size
            implicitHeight: root.size
            Window {
                anchors.centerIn: parent
            }
        }

        Item {
            id: clock
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 300
            }
            implicitWidth: root.size
            implicitHeight: root.size
            Clock {
                anchors.centerIn: parent
            }
        }

        Item {
            id: screenshotTrigger
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 135
            }
            implicitWidth: root.size
            implicitHeight: root.size
            Screenshot {
                anchors.centerIn: parent
                onClicked: {
                    screenshotPopup.visible = !screenshotPopup.visible
                    screenshotReveal.open = screenshotPopup.visible
                }
            }
        }

        Item {
            id: batteryTrigger
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 100
            }
            implicitWidth: root.size
            implicitHeight: root.size
            Battery {
                id: batteryIcon
                anchors.centerIn: parent
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: { batteryPopup.visible = true; batteryReveal.open = true }
                onExited:  {
                    batteryReveal.open = false
                    hideBatteryTimer.start()
                }
            }
            Timer {
                id: hideBatteryTimer
                interval: 500
                onTriggered: batteryPopup.visible = false
            }
        }

        Item {
            id: btTrigger
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 70
            }
            implicitWidth: root.size
            implicitHeight: root.size

            Bluetooth {
                anchors.centerIn: parent
                onClicked: {
                    btPopup.visible = !btPopup.visible
                    btReveal.open = btPopup.visible
                }
            }
        }

        Item {
            id: wifiTrigger
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 40
            }
            implicitWidth: root.size
            implicitHeight: root.size

            Wifi {
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: { wifiPopup.visible = true; wifiReveal.open = true }
                onExited:  {
                    wifiReveal.open = false
                    hideWifiTimer.start()
                }
            }

            Timer {
                id: hideWifiTimer
                interval: 500
                onTriggered: wifiPopup.visible = false
            }
        }
    }

    // ───────────────────────
    // POPUPS
    // ───────────────────────

    PopupWindow {
        id: wifiPopup
        visible: false
        implicitWidth: 180
        implicitHeight: 50
        color: "transparent"

        anchor {
            window: root
            rect.x: 40
            rect.y: 1100
        }

        AnimatedReveal {
            id: wifiReveal
            anchors.fill: parent
            open: false

            WifiMenu {
                anchors.fill: parent
            }
        }
    }

    PopupWindow {
        id: batteryPopup
        visible: false
        implicitWidth: 180
        implicitHeight: 60
        color: "transparent"

        anchor {
            window: root
            rect.x: 40
            rect.y: 980
        }

        AnimatedReveal {
            id: batteryReveal
            anchors.fill: parent
            open: false

            BatteryPopup {
                anchors.fill: parent
            }
        }
    }

    PopupWindow {
        id: btPopup
        visible: false
        implicitWidth: 250
        implicitHeight: 300
        color: "transparent"

        anchor {
            window: root
            rect.x: 40
            rect.y: 1050
        }

        AnimatedReveal {
            id: btReveal
            anchors.fill: parent
            open: false

            BluetoothMenu {
                anchors.fill: parent
            }
        }
    }

    PopupWindow {
        id: screenshotPopup
        visible: false
        implicitWidth: 180
        implicitHeight: 120
        color: "transparent"

        anchor {
            window: root
            rect.x: 40
            rect.y: 900
        }

        AnimatedReveal {
            id: screenshotReveal
            anchors.fill: parent
            open: false

            ScreenshotMenu {
                anchors.fill: parent
            }
        }
    }
}
