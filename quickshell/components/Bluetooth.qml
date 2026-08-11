import Quickshell
import Quickshell.Io
import QtQuick
import qs.config.theme

Item {
    id: root

    property bool powered: false
    property bool connected: false

    implicitWidth: 32
    implicitHeight: 32

    function queryStatus() {
        btPowerProc.running = true
        btConnectedProc.running = true
    }

    Process {
        id: btPowerProc
        command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo on || echo off"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.powered = this.text.trim() === "on"
            }
        }
    }

    Process {
        id: btConnectedProc
        command: ["bash", "-c", "bluetoothctl devices Connected | grep -q . && echo yes || echo no"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.connected = this.text.trim() === "yes"
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            btPowerProc.running = true
            btConnectedProc.running = true
        }
    }

    property string icon: {
        if (!root.powered) return "󰂲"
        if (root.connected) return "󰂱"
        return "󰂯"
    }
    property string iconColor: {
        if (!root.powered) return Colors.palette.base03
        if (root.connected) return Colors.palette.base06
        return Colors.palette.base05
    }

    Text {
        id: btIcon
        text: root.icon
        color: root.iconColor
        font.pixelSize: 20
        // horizontalAlignment: Text.AlignHCenter
        anchors.centerIn: parent
    }

}
