import Quickshell
import QtQuick
import "../components"
import qs.config.theme

PanelWindow {
    id: root
    anchors { top: true; left: true; bottom: true }
    property int marg: 0
    margins { left: root.marg; top: root.marg; bottom: root.marg; right: root.marg }
    color: "transparent"
    implicitWidth: 40

    Rectangle {
        anchors.fill: parent
        color: Colors.palette.base00
        border.color: Qt.alpha(Colors.palette.base04, 0.5)
        border.width: 0
        radius: 0

        Workspaces {
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 15 }
        }

        BarButton {
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 200 }
            implicitHeight: 500
            bgEnable: false
            Window { anchors.centerIn: parent }
        }

        BarButton {
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 250 }
            implicitHeight: 80
            active: calendarPopup.open
            Clock { anchors.centerIn: parent }
            onClicked: calendarPopup.toggle()
        }

        Column {
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 40 }
            spacing: 4

            BarButton {
                iconText: ""
                active: toolsPopup.open
                onClicked: toolsPopup.toggle()
            }

            BarButton {
                active: batteryPopup.open
                Battery { anchors.centerIn: parent }
                onClicked: batteryPopup.toggle()
            }

            BarButton {
                active: btPopup.open
                Bluetooth { anchors.centerIn: parent }
                onClicked: btPopup.toggle()
            }

            BarButton {
                active: wifiPopup.open
                Wifi { anchors.centerIn: parent }
                onClicked: wifiPopup.toggle()
            }
        }
    }

    // Popups
    BarPopup {
        id: calendarPopup
        implicitWidth: 220
        implicitHeight: 270
        anchorWindow: root
        anchorY: root.height - 402
        contentComponent: Component {
            CalendarPopup {
                onCloseRequested: calendarPopup.close()
            }
        }
    }

    BarPopup {
        id: toolsPopup
        implicitWidth: 180
        implicitHeight: 220
        anchorWindow: root
        anchorY: root.height - 255
        contentComponent: Component {
            ToolsMenu {
                onCloseRequested: toolsPopup.close()
            }
        }
    }

    BarPopup {
        id: batteryPopup
        implicitWidth: 180
        implicitHeight: 220
        anchorWindow: root
        anchorY: root.height - 220
        contentComponent: Component {
            BatteryPopup {
                onCloseRequested: batteryPopup.close()
            }
        }
    }

    BarPopup {
        id: btPopup
        implicitWidth: 250
        implicitHeight: 300
        anchorWindow: root
        anchorY: root.height - 20
        contentComponent: Component {
            BluetoothMenu {
                onCloseRequested: btPopup.close()
            }
        }
    }

    BarPopup {
        id: wifiPopup
        implicitWidth: 200
        implicitHeight: 100
        anchorWindow: root
        anchorY: root.height
        contentComponent: Component {
            WifiMenu {
                onCloseRequested: wifiPopup.close()
            }
        }
    }
}
