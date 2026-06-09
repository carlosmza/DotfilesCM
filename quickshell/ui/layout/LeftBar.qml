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
        radius: 15
        clip: false   // ¡importante para que los popups se vean!

        // ── Workspaces ──
        Item {
            id: workspaces
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 20
            }
            Workspaces {
                anchors.centerIn: parent
            }
        }

        // ── Window ──
        Item {
            id: windows
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 300
            }
            implicitWidth: 32
            implicitHeight: 32
            Window {
                anchors.centerIn: parent
            }
        }

        // ── Clock (sin popup) ──
        Item {
            id: clock
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 500
            }
            implicitWidth: 32
            implicitHeight: 32
            Clock {
                anchors.centerIn: parent
            }
        }

        // ── Screenshot con popup ──
        Item {
            id: screenshotTrigger
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 140
            }
            implicitWidth: 32
            implicitHeight: 32

            Screenshot {
                anchors.centerIn: parent
                onClicked: {
                    screenshotPopup.visible = !screenshotPopup.visible
                    screenshotReveal.open = screenshotPopup.visible
                }
            }
        }

        // ── Battery con popup ──
        Item {
            id: batteryTrigger
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 100
            }
            implicitWidth: 32
            implicitHeight: 32

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

        // ── Bluetooth con popup ──
        Item {
            id: btTrigger
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 80
            }
            implicitWidth: 32
            implicitHeight: 32

            Bluetooth {
                anchors.centerIn: parent
                onClicked: {
                    btPopup.visible = !btPopup.visible
                    btReveal.open = btPopup.visible
                }
            }
        }

        // ── Wifi con popup ──
        Item {
            id: wifiTrigger
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 40
            }
            implicitWidth: 32
            implicitHeight: 32

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
