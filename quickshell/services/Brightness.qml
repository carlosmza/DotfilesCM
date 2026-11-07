import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    visible: false

    property real brightnessValue: 0
    property bool backlightAvailable: false
    property int threshold: 90
    property bool _booted: false

    signal valueChanged()

    Process {
        id: detector
        running: true

        command: [
            "sh", "-c",
            "d=$(ls /sys/class/backlight/ | head -1); [ -n \"$d\" ] && echo \"$d\" || echo \"N/A\""
        ]

        stdout: SplitParser {
            onRead: data => {
                const device = data.trim()
                if (device !== "N/A" && device.length > 0) {
                    root.backlightAvailable = true
                    streamer.running = true
                }
            }
        }
    }

    Process {
        id: streamer
        running: false

        command: [
            "sh", "-c",
            "while :; do brightnessctl -m; sleep 0.2; done"
        ]

        stdout: SplitParser {
            onRead: data => root._parse(data)
        }
    }

    function _parse(line) {
        const fields = line.trim().split(",")
        const pct = Math.round(parseFloat(fields[3]))
        if (isNaN(pct)) return
        if (pct !== root.brightnessValue) {
            root.brightnessValue = pct
            if (root._booted) root.valueChanged()
        }
    }

    Component.onCompleted: Qt.callLater(() => root._booted = true)
    Component.onDestruction: {
        streamer.running = false
        detector.running = false
    }
}