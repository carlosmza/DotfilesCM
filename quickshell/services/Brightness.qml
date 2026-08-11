import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    visible: false

    property real brightnessValue: 0
    property bool backlightAvailable: false
    property int threshold: 80

    signal valueChanged()

    Process {
        id: deviceDetector
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
                    brightnessReader.running = true
                    brightnessWatcher.running = true
                }
            }
        }
    }

    Process {
        id: brightnessWatcher
        running: false

        command: [
            "sh", "-c",
            "d=$(ls /sys/class/backlight/ | head -1); exec inotifywait -m -e modify \"/sys/class/backlight/$d/brightness\" 2>/dev/null"
        ]

        stdout: SplitParser {
            onRead: data => {
                brightnessReader.running = true
                root.valueChanged()
            }
        }
    }

    Process {
        id: brightnessReader
        running: false

        command: [
            "sh", "-c",
            "d=$(ls /sys/class/backlight/ | head -1); [ -n \"$d\" ] && awk 'FNR==1 && NR==1{b=$1} FNR==1 && NR==2{print int(b*100/$1)}' \"/sys/class/backlight/$d/brightness\" \"/sys/class/backlight/$d/max_brightness\""
        ]

        stdout: SplitParser {
            onRead: data => {
                const val = parseInt(data)
                if (!isNaN(val)) {
                    root.brightnessValue = val
                }
            }
        }
    }

    Component.onDestruction: {
        brightnessWatcher.running = false
        brightnessReader.running = false
        deviceDetector.running = false
    }
}
