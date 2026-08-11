import Quickshell
import Quickshell.Io
import QtQuick
import "../components"
import qs.config.theme

PanelWindow {
    id: root
    anchors { top: true; left: true; bottom: true}
    margins { left: 5; top: 5; bottom: 5; right: 5 }
    color: "transparent"
    implicitWidth: 40

    Rectangle {
        anchors.fill: parent
        color: Colors.palette.base00
        border.color: "#7F" + Colors.palette.base04.slice(1) // Implementacion de alpha #AARRGGBB
        border.width: 1
        clip: false
        radius: 10
        Item {
            id: workspaces
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 40 }
            Workspaces {
                anchors.centerIn: parent
            }
        }
        BarButtom {
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 400 }
            Window { anchors.centerIn: parent }
            implicitHeight: 160
            bgEnable: false
        }
        BarButtom {
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 250 }
            Clock { anchors.centerIn: parent }
            implicitHeight: 64
        }
        BarButtom {
            id: toolsBtn
            iconText: ""
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 148 }
            active: toolsPopup.visible
            autoHideDelay: 150
            onClicked: {
                toolsPopup.visible = !toolsPopup.visible
                toolsReveal.open = toolsPopup.visible
            }
            onHoverEntered: {
                toolsCloseTimer.stop()
                toolsPopup.visible = true
                toolsReveal.open = true
            }
            onHoverExited: {
                toolsCloseTimer.restart()
            }
        }
        BarButtom {
            id: batteryBtn
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 112 }
            active: batteryPopup.visible
            autoHideDelay: 150
            Battery { anchors.centerIn: parent }
            onClicked: {
                batteryPopup.visible = !batteryPopup.visible
                batteryReveal.open = batteryPopup.visible
            }
            onHoverEntered: {
                batteryCloseTimer.stop()
                batteryPopup.visible = true
                batteryReveal.open = true
            }
            onHoverExited: {
                batteryCloseTimer.restart()
            }
        }
        BarButtom {
            id: btBtn
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 76 }
            active: btPopup.visible
            autoHideDelay: 150
            Bluetooth { anchors.centerIn: parent }
            onClicked: {
                btPopup.visible = !btPopup.visible
                btReveal.open = btPopup.visible
            }
            onHoverEntered: {
                btCloseTimer.stop()
                btPopup.visible = true
                btReveal.open = true
            }
            onHoverExited: {
                btCloseTimer.restart()
            }
        }
        BarButtom {
            id: wifiBtn
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 40 }
            active: wifiPopup.visible
            autoHideDelay: 150
            Wifi { anchors.centerIn: parent }
            onClicked: {
                wifiPopup.visible = !wifiPopup.visible
                wifiReveal.open = wifiPopup.visible
            }
            onHoverEntered: {
                wifiCloseTimer.stop()
                wifiPopup.visible = true
                wifiReveal.open = true
            }
            onHoverExited: {
                wifiCloseTimer.restart()
            }
        }
    }
    // Popups
    PopupWindow {
        id: toolsPopup
        color: "transparent"
        implicitWidth: 180; implicitHeight: 220
        visible: false
        property bool hovered: false
        anchor { window: root; rect.x: 40; rect.y: 815 }
        onVisibleChanged: {
            if (visible) toolsContent.forceActiveFocus()
        }
        Timer {
            id: toolsCloseTimer
            interval: 200
            onTriggered: {
                if (!toolsPopup.hovered && !toolsBtn.hovered) {
                    toolsPopup.visible = false
                    toolsReveal.open = false
                }
            } 
        }
        AnimatedReveal {
            id: toolsReveal
            anchors.fill: parent
            open: false
            ToolsMenu {
                id: toolsContent
                anchors.fill: parent
                onCloseRequested: {
                    toolsPopup.visible = false
                    toolsReveal.open = false
                }
            }
            HoverHandler {
                onHoveredChanged: {
                    if (hovered) { toolsPopup.hovered = true; toolsCloseTimer.stop() }
                    else { toolsPopup.hovered = false; toolsCloseTimer.restart() }
                }
            }
        }
    }
    PopupWindow {
        id: batteryPopup
        color: "transparent"
        implicitWidth: 180; implicitHeight: 220
        visible: false
        property bool hovered: false
        anchor { window: root; rect.x: 40; rect.y: 850 }
        Timer { 
            id: batteryCloseTimer
            interval: 200
            onTriggered: {
                if (!batteryPopup.hovered && !batteryBtn.hovered) {
                    batteryPopup.visible = false
                    batteryReveal.open = false
                }
            } 
        }
        AnimatedReveal {
            id: batteryReveal
            anchors.fill: parent
            open: false
            BatteryPopup { anchors.fill: parent }
            HoverHandler {
                onHoveredChanged: {
                    if (hovered) { batteryPopup.hovered = true; batteryCloseTimer.stop() }
                    else { batteryPopup.hovered = false; batteryCloseTimer.restart() }
                }
            }
        }
    }
    PopupWindow {
        id: btPopup
        color: "transparent"
        implicitWidth: 250; implicitHeight: 300
        visible: false
        property bool hovered: false
        anchor { window: root; rect.x: 40; rect.y: 1050 }
        Timer {
            id: btCloseTimer
            interval: 200
            onTriggered: {
                if (!btPopup.hovered && !btBtn.hovered) {
                    btPopup.visible = false
                    btReveal.open = false
                }
            } 
        }
        AnimatedReveal {
            id: btReveal
            anchors.fill: parent
            open: false
            BluetoothMenu { anchors.fill: parent }
            HoverHandler {
                onHoveredChanged: {
                    if (hovered) { btPopup.hovered = true; btCloseTimer.stop() }
                    else { btPopup.hovered = false; btCloseTimer.restart() }
                }
            }
        }
    }
    PopupWindow {
        id: wifiPopup
        color: "transparent"
        implicitWidth: 200; implicitHeight: 100
        visible: false
        property bool hovered: false
        anchor { window: root; rect.x: 40; rect.y: 1070 }
        Timer {
            id: wifiCloseTimer
            interval: 200
            onTriggered: {
                if (!wifiPopup.hovered && !wifiBtn.hovered) {
                    wifiPopup.visible = false
                    wifiReveal.open = false
                }
            } 
        }
        AnimatedReveal {
            id: wifiReveal
            anchors.fill: parent
            open: false
            WifiMenu { anchors.fill: parent }
            HoverHandler {
                onHoveredChanged: {
                    if (hovered) { wifiPopup.hovered = true; wifiCloseTimer.stop() }
                    else { wifiPopup.hovered = false; wifiCloseTimer.restart() }
                }
            }
        }
    }
}
