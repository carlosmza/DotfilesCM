import Quickshell
import Quickshell.Io
import QtQuick
import "../components"
import qs.config.theme

MenuLayout {
    id: root
    title: ""

    property bool connected: false
    property string ssid: ""
    property int signal: 0

    property var icons: ["󰤭", "󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
    property string icon: {
        if (!root.connected) return icons[0]
        var p = Math.max(0, Math.min(100, root.signal))
        if (p <= 10) return icons[1]
        if (p <= 30) return icons[2]
        if (p <= 60) return icons[3]
        if (p <= 85) return icons[4]
        return icons[5]
    }
    property string iconColor: root.connected
        ? (root.signal <= 20 ? Colors.palette.base08 : Colors.palette.base06)
        : Colors.palette.base03

    Timer {
        id: refreshTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            infoProc.running = true
        }
    }

    Process {
        id: infoProc
        command: ["bash", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes' || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim()
                if (!out) {
                    root.connected = false
                    root.ssid = ""
                    root.signal = 0
                    return
                }
                var parts = out.split(":")
                if (parts.length >= 3) {
                    root.connected = parts[0] === "yes"
                    root.ssid = parts[1] || ""
                    root.signal = parseInt(parts[2]) || 0
                }
            }
        }
    }

    Row {
        spacing: 8
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            text: root.icon
            color: root.iconColor
            font.pixelSize: 24
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.connected ? root.ssid : "Not connected"
            color: root.connected ? Colors.palette.base05 : Colors.palette.base03
            font.pixelSize: 13
            font.weight: Font.Bold
            font.italic: !root.connected
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Colors.palette.base03
    }

    Rectangle {
        width: parent.width
        height: 6
        radius: 3
        color: Colors.palette.base01

        Rectangle {
            height: parent.height
            radius: 3
            color: root.connected ? Colors.palette.base0D : Colors.palette.base03
            width: parent.width * (root.signal / 100)
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.connected ? root.signal + "% — Connected" : "No connection"
        color: Colors.palette.base04
        font.pixelSize: 12
    }
}
