import QtQuick
import Quickshell.Io
import qs.config.theme

Item {
    id: root

    property bool powered: false
    property bool connected: false

    implicitWidth: 32
    implicitHeight: 32

    readonly property string icon: {
        if (!root.powered)
            return "󰂲"
        if (root.connected)
            return "󰂱"
        return "󰂯"
    }

    readonly property color iconColor: {
        if (!root.powered)
            return Colors.palette.base03
        if (root.connected)
            return Colors.palette.base06
        return Colors.palette.base05
    }

    Process {
        id: statusProc
        command: [
            "bash", "-c",
            "p=off; bluetoothctl show | grep -q 'Powered: yes' && p=on; "
            + "c=no; bluetoothctl devices Connected | grep -q . && c=yes; "
            + "echo \"$p $c\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = this.text.trim().split(" ")
                root.powered = parts[0] === "on"
                root.connected = parts[1] === "yes"
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: statusProc.running = true
    }

    Component.onCompleted: statusProc.running = true

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.iconColor
        font.pixelSize: 20
    }
}
