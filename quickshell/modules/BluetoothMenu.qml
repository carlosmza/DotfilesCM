pragma ComponentBehavior: Bound

import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../components"
import qs.config.theme
import qs.config.fonts

MenuLayout {
    id: root

    property string font: Fonts.varelaRound
    property bool btPowered: false
    property bool scanning: true
    property var devices: []
    property string notifText: ""

    Component.onCompleted: refreshStatus()

    function refreshStatus() {
        powerCheckProc.running = true
        scanCheckProc.running = true
        deviceListProc.running = true
    }

    function togglePower() {
        togglePowerProc.command = ["bluetoothctl", "power", root.btPowered ? "off" : "on"]
        togglePowerProc.running = true
    }

    function toggleScan() {
        if (root.scanning)
            toggleScanProc.command = ["bluetoothctl", "scan", "off"]
        else
            toggleScanProc.command = ["bash", "-c", "bluetoothctl -- scan on > /dev/null 2>&1 & sleep 1"]
        toggleScanProc.running = true
    }

    function pairDevice(mac, name) {
        root.notifText = "Pairing with " + name + "..."
        pairNotif.show()
        pairProc.command = ["bash", "-c", "bluetoothctl pair " + mac + " 2>&1 | tail -1"]
        pairProc.running = true
    }

    Process {
        id: powerCheckProc
        command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo on || echo off"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.btPowered = this.text.trim() === "on"
            }
        }
    }

    Process {
        id: scanCheckProc
        command: ["bash", "-c", "bluetoothctl show | grep -q 'Discovering: yes' && echo on || echo off"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.scanning = this.text.trim() === "on"
            }
        }
    }

    Process {
        id: deviceListProc
        command: ["bash", "-c", "bluetoothctl devices | awk '{print $2 \"|\" substr($0, index($0,$3))}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var text = this.text.trim()
                if (text === "") {
                    root.devices = []
                    return
                }
                var lines = text.split("\n")
                var list = []
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split("|")
                    if (parts.length >= 2)
                        list.push({ mac: parts[0], name: parts[1], connected: false })
                }
                root.devices = list
                connectedListProc.running = true
            }
        }
    }

    Process {
        id: connectedListProc
        command: ["bash", "-c", "bluetoothctl devices Connected | awk '{print $2}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var text = this.text.trim()
                var connected = text === "" ? [] : text.split("\n")
                var list = []
                for (var i = 0; i < root.devices.length; i++) {
                    var device = root.devices[i]
                    list.push({
                        mac: device.mac,
                        name: device.name,
                        connected: connected.indexOf(device.mac) !== -1
                    })
                }
                root.devices = list
            }
        }
    }

    Process {
        id: togglePowerProc
        onRunningChanged: {
            if (!running)
                powerCheckProc.running = true
        }
    }

    Process {
        id: toggleScanProc
        onRunningChanged: {
            if (!running)
                scanCheckProc.running = true
        }
    }

    Process {
        id: pairProc
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim().toLowerCase()
                root.notifText = (out.indexOf("successful") !== -1 || out.indexOf("already") !== -1)
                    ? "Paired successfully"
                    : "Pairing failed"
                pairNotif.show()
                root.refreshStatus()
            }
        }
    }

    Process {
        id: connectProc
    }

    component DeviceRow: Rectangle {
        id: delegateRow

        required property var modelData

        readonly property bool isConnected: modelData.connected

        width: parent.width
        height: 34
        radius: 6
        color: rowMouse.containsMouse ? Colors.palette.base03 : "transparent"

        Behavior on color { ColorAnimation { duration: 150 } }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                connectProc.command = [
                    "bluetoothctl",
                    delegateRow.isConnected ? "disconnect" : "connect",
                    delegateRow.modelData.mac
                ]
                connectProc.running = true
                root.refreshStatus()
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 4
            spacing: 4

            Text {
                text: "󰂱"
                color: Colors.palette.base0B
                font.pixelSize: 14
                visible: delegateRow.isConnected
                Layout.preferredWidth: 14
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: delegateRow.modelData.name
                    color: Colors.palette.base05
                    font.pixelSize: 14
                    font.family: root.font
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: delegateRow.modelData.mac + (delegateRow.isConnected ? " (connected)" : "")
                    color: Colors.palette.base03
                    font.pixelSize: 12
                    font.family: "monospace"
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 26
                Layout.alignment: Qt.AlignVCenter
                radius: 6
                color: Colors.palette.base01
                visible: !delegateRow.isConnected

                Text {
                    anchors.centerIn: parent
                    text: "󰐗"
                    color: Colors.palette.base05
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.pairDevice(delegateRow.modelData.mac, delegateRow.modelData.name)
                }
            }
        }
    }

    Text {
        text: "Bluetooth"
        color: Colors.palette.base05
        font.pixelSize: 15
        font.weight: Font.Bold
        font.family: root.font
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.btPowered ? "On" : "Off"
        color: root.btPowered ? Colors.palette.base0B : Colors.palette.base08
        font.pixelSize: 12
        font.family: root.font
    }

    MenuSeparator {}

    Row {
        width: parent.width
        spacing: 6
        visible: root.btPowered

        Rectangle {
            width: parent.width - 86
            height: 32
            radius: 8
            color: Colors.palette.base02

            Text {
                text: "Disable"
                color: Colors.palette.base05
                font.pixelSize: 13
                font.family: root.font
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 32
                height: 18
                radius: 9
                color: root.btPowered ? Colors.palette.base0B : Colors.palette.base03
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    x: root.btPowered ? parent.width - width - 2 : 2
                    y: 2
                    width: 14
                    height: 14
                    radius: 7
                    color: Colors.palette.base00
                }

                Behavior on x { NumberAnimation { duration: 150 } }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.togglePower()
            }
        }

        Rectangle {
            width: 80
            height: 32
            radius: 8
            color: root.scanning ? Colors.palette.base0D : Colors.palette.base02

            Row {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: "󰂰"
                    color: Colors.palette.base00
                    font.pixelSize: 16

                    RotationAnimation on rotation {
                        running: root.scanning
                        from: 0
                        to: 360
                        duration: 1500
                        loops: Animation.Infinite
                    }
                }

                Text {
                    text: "Scan"
                    color: Colors.palette.base00
                    font.pixelSize: 13
                    font.family: root.font
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggleScan()
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 32
        radius: 8
        color: Colors.palette.base02
        visible: !root.btPowered

        Text {
            anchors.centerIn: parent
            text: "Enable Bluetooth"
            color: Colors.palette.base05
            font.pixelSize: 13
            font.family: root.font
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.togglePower()
        }
    }

    MenuSeparator {
        visible: root.btPowered && root.devices.length > 0
    }

    MenuSection {
        label: "DEVICES"
        visible: root.btPowered && root.devices.length > 0
    }

    Repeater {
        model: root.devices
        visible: root.btPowered && root.devices.length > 0

        delegate: DeviceRow {}
    }

    Text {
        width: parent.width
        visible: root.btPowered && root.devices.length === 0
        text: "No devices found.\nEnable scan to discover."
        color: Colors.palette.base03
        font.pixelSize: 12
        font.family: root.font
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
    }

    overlay: Item {
        height: 36

        Notification {
            id: pairNotif
            icon: ""
            label: root.notifText
            duration: 2000
        }
    }
}
