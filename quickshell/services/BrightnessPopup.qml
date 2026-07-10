import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.config.theme

ShellRoot {
    id: root

    property real brightnessValue: 0
    property bool backlightAvailable: false
    property int threshold: 80

    // 🔍 Detecta el dispositivo de backlight al inicio
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

    // 👁️ Watcher: se dispara cuando el brillo cambia
    Process {
        id: brightnessWatcher
        running: false

        command: [
            "sh", "-c",
            "d=$(ls /sys/class/backlight/ | head -1); exec inotifywait -m -e modify \"/sys/class/backlight/$d/brightness\" 2>/dev/null"
        ]

        stdout: SplitParser {
            onRead: data => {
                osdItem.mostrar = true
                hideTimer.restart()
                brightnessReader.running = true
            }
        }
    }

    // 📖 Lector: obtiene el valor actual del brillo
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

    PanelWindow {
        id: osdPanel
        anchors { top: true }
        implicitWidth: 310
        implicitHeight: 40
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.margins { top: Math.round(Screen.height * 0.12) }
        color: "transparent"

        Rectangle {
            id: osdItem
            property bool mostrar: false
            anchors.fill: parent
            anchors.topMargin: mostrar ? 0 : -30
            color: Colors.palette.base00
            radius: 6
            opacity: mostrar ? 1.0 : 0.0
            visible: opacity > 0.0
            enabled: opacity > 0.0

            Behavior on opacity {
                NumberAnimation { duration: 400 }
            }

            Behavior on anchors.topMargin {
                NumberAnimation { duration: 300; easing: Easing.OutCubic }
            }

            Timer {
                id: hideTimer
                interval: 1500
                repeat: false
                onTriggered: osdItem.mostrar = false
            }

            Rectangle {
                id: fgItem
                anchors.fill: parent
                anchors.rightMargin: Math.min(osdPanel.implicitWidth - root.brightnessValue * 3, 305)
                anchors.leftMargin: 5
                anchors.topMargin: 5
                anchors.bottomMargin: 5
                color: backlightAvailable ? Colors.palette.base02 : Colors.palette.base01
                radius: 6

                Behavior on anchors.rightMargin {
                    NumberAnimation { duration: 200 }
                }

                Text {
                    text: "󰃟"
                    color: root.brightnessValue < root.threshold ? Colors.palette.base05 : Colors.palette.base06
                    font.pixelSize: 18
                    x: root.brightnessValue < root.threshold ? osdPanel.implicitWidth - 50 : osdPanel.implicitWidth - 100
                    y: 5
                }
            }

            Rectangle {
                id: levelItem
                width: 5
                height: parent.height - 10
                color: Colors.palette.base05
                radius: 6
                x: Math.max(root.brightnessValue * 3 - 2, 5)
                y: 5

                Behavior on x {
                    NumberAnimation { duration: 200 }
                }
            }
        }
    }
}
