import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.config.theme
import qs.config.fonts
import "../layout"

Rectangle {
    id: root
    anchors.fill: parent
    color: Colors.palette.base00
    radius: 15
    clip: true

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
        connectedListProc.running = true
    }

    function togglePower() {
        var cmd = root.btPowered ? "bluetoothctl power off" : "bluetoothctl power on"
        togglePowerProc.command = ["bash", "-c", cmd]
        togglePowerProc.running = true
    }

    function toggleScan() {
        if (root.scanning) {
            toggleScanProc.command = ["bash", "-c", "bluetoothctl scan off"]
        } else {
            toggleScanProc.command = ["bash", "-c", "bluetoothctl -- scan on > /dev/null 2>&1 & sleep 1"]
        }
        toggleScanProc.running = true
    }

    function pairDevice(mac, name) {
        root.notifText = "Pairing with " + name + "..."
        pairNotif.show()
        pairProc.command = ["bash", "-c", "bluetoothctl pair " + mac + " 2>&1 | tail -1"]
        pairProc.running = true
    }

    function connectDevice(mac) {
        connectProc.command = ["bash", "-c", "bluetoothctl connect " + mac]
        connectProc.running = true
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
                    if (parts.length >= 2) {
                        list.push({ mac: parts[0], name: parts[1], connected: false })
                    }
                }
                root.devices = list
            }
        }
    }

    Process {
        id: togglePowerProc
        command: ["bash"]
        onRunningChanged: {
            if (!running) {
                powerCheckProc.running = true
            }
        }
    }

    Process {
        id: toggleScanProc
        command: ["bash"]
        onRunningChanged: {
            if (!running) {
                scanCheckProc.running = true
            }
        }
    }

    Process {
        id: pairProc
        command: ["bash"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim().toLowerCase()
                if (out.indexOf("successful") !== -1 || out.indexOf("already") !== -1) {
                    root.notifText = "Paired successfully"
                } else {
                    root.notifText = "Pairing failed"
                }
                pairNotif.show()
                root.refreshStatus()
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
                for (var i = 0; i < root.devices.length; i++) {
                    root.devices[i].connected = connected.indexOf(root.devices[i].mac) !== -1
                }
                root.devices = root.devices
            }
        }
    }

    Process {
        id: connectProc
        command: ["bash"]
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 6

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: ""
                color: root.btPowered ? Colors.palette.base0D : Colors.palette.base03
                font.pixelSize: 20
            }

            Text {
                text: "Bluetooth"
                color: Colors.palette.base05
                font.pixelSize: 15
                font.weight: Font.Bold
                font.family: root.font
            }

            Item { Layout.fillWidth: true }

            Text {
                text: root.btPowered ? "On" : "Off"
                color: root.btPowered ? Colors.palette.base0B : Colors.palette.base08
                font.pixelSize: 12
                font.family: root.font
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colors.palette.base03
        }

        // Combined row: Enable/Disable + Scan
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: root.btPowered

            // Enable/Disable toggle
            Rectangle {
                Layout.fillWidth: true
                height: 32
                radius: 8
                color: Colors.palette.base02

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 6

                    Text {
                        text: root.btPowered ? "Disable" : "Enable"
                        color: Colors.palette.base05
                        font.pixelSize: 13
                        font.family: root.font
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 32
                        height: 18
                        radius: 9
                        color: root.btPowered ? Colors.palette.base0B : Colors.palette.base03

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
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.togglePower()
                }
            }

            // Scan button
            Rectangle {
                Layout.preferredWidth: 80
                height: 32
                radius: 8
                color: root.scanning ? Colors.palette.base0D : Colors.palette.base02

                RowLayout {
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

        // Off state (show enable button only)
        Rectangle {
            Layout.fillWidth: true
            height: 32
            radius: 8
            color: Colors.palette.base02
            visible: !root.btPowered

            RowLayout {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "󰂰 Enable Bluetooth"
                    color: Colors.palette.base05
                    font.pixelSize: 13
                    font.family: root.font
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.togglePower()
            }
        }

        // Devices list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: Colors.palette.base02
            visible: root.btPowered && root.devices.length > 0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 2

                Text {
                    text: "Devices"
                    color: Colors.palette.base04
                    font.pixelSize: 11
                    font.family: root.font
                    leftPadding: 6
                    topPadding: 4
                }

                ListView {
                    id: deviceList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.devices
                    spacing: 2

                    delegate: Rectangle {
                        width: deviceList.width
                        height: 34
                        radius: 6
                        color: mA.containsMouse ? Colors.palette.base03 : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 4
                            spacing: 4

                            Text {
                                text: "󰂱"
                                color: Colors.palette.base0B
                                font.pixelSize: 14
                                visible: modelData.connected
                                Layout.preferredWidth: 14
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: modelData.name
                                    color: Colors.palette.base05
                                    font.pixelSize: 12
                                    font.family: root.font
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Text {
                                    text: modelData.mac + (modelData.connected ? " (connected)" : "")
                                    color: Colors.palette.base03
                                    font.pixelSize: 9
                                    font.family: "monospace"
                                    width: parent.width
                                    elide: Text.ElideRight
                                }
                            }

                            Rectangle {
                                width: 28
                                height: 26
                                radius: 6
                                color: Colors.palette.base01
                                visible: !modelData.connected

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
                                    onClicked: {
                                        root.pairDevice(modelData.mac, modelData.name)
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: mA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.connected) {
                                    connectProc.command = ["bash", "-c", "bluetoothctl disconnect " + modelData.mac]
                                } else {
                                    connectProc.command = ["bash", "-c", "bluetoothctl connect " + modelData.mac]
                                }
                                connectProc.running = true
                                root.refreshStatus()
                            }
                        }
                    }
                }
            }
        }

        // Empty state
        Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.btPowered && root.devices.length === 0
            text: "No devices found.\nEnable scan to discover."
            color: Colors.palette.base03
            font.pixelSize: 12
            font.family: root.font
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
        }
    }

    // Notification overlay
    Item {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 36
        z: 30

        Notification {
            id: pairNotif
            icon: ""
            label: root.notifText
            value: -1
            duration: 2000
        }
    }
}
