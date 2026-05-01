import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // API
    property bool connected: false
    property int signal: 0
    property string ssid: ""
    property bool tooltipVisible: false

    implicitWidth: 30
    implicitHeight: 10

    // Try NetworkManager first
    Process {
        id: nmcliProc
        command: ["bash", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes' || true"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim()
                if (!out) {
                    // leave fallback to other procs
                    return
                }
                var parts = out.split(":")
                if (parts.length >= 3 && (parts[0] === "yes" || parts[0] === "*")) {
                    root.connected = true
                    root.ssid = parts[1] || ""
                    root.signal = parseInt(parts[2]) || 0
                } else {
                    root.connected = false
                    root.ssid = ""
                    root.signal = 0
                }
            }
        }
    }


    Timer {
        id: refreshTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            nmcliProc.running = true
        }
    }
    // Icons (nerdfont) for signal intervals. Adjust glyphs if your font differs.
    // property var icons: ["󰤯", "󰤰", "󰤱", "󰤲", "󰤳"]
    property var icons: ["󰤭", "󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
    property string icon: {
        if (!root.connected) return icons[0]
        var p = Math.max(0, Math.min(100, parseInt(root.signal)))
        if (p <= 10) return icons[1]
        if (p <= 30) return icons[2]
        if (p <= 60) return icons[3]
        if (p <= 85) return icons[4]
        return icons[5]
    }
    property string icon_color: root.connected ? (root.signal <= 20 ? "#ff5555" : "white") : "#666666"

    Text {
        id: wifiIcon
        text: root.icon
        color: root.icon_color
        font.pixelSize: 18
        horizontalAlignment: Text.AlignHCenter
    }
}
