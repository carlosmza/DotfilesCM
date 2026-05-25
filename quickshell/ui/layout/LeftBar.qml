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

        Workspaces {
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
        }

        Window {
            anchors {
                centerIn: parent
            }
        }
        // ── Clock (sin popup) ──
        Clock {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
        }
        // ── Battery con popup ──
        Item {
            id: batteryTrigger
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                margins: 50
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

        // ── Wifi con popup ──
        Item {
            id: wifiTrigger
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                margins: 28
            }
            implicitWidth: 32
            implicitHeight: 32

            Wifi {
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    // margins: 28
                }
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

        // … similar pattern …
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

    // … más PopupWindows para Battery, etc.
}
