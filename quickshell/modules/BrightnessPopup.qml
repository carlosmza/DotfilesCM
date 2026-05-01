import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

ShellRoot {
    id: root

    // 🔆 Estado del brillo
    property real brightnessValue: 0
    property real maxBrightness: 100

    // 👁️ Watcher: se dispara cuando el archivo cambia
    Process {
        id: brightnessWatcher
        running: true

        // inotifywait espera cambios en el archivo y los imprime
        command: [
            "sh", "-c",
            "inotifywait -m -e modify /sys/class/backlight/*/brightness 2>/dev/null"
        ]

        stdout: SplitParser {
            onRead: data => {
                console.log("cambio:", data)
                osdItem.mostrar = true
                hideTimer.restart()
                brightnessReader.running = true
            }
        }
    }

    // 📖 Lector: obtiene el valor actual del brillo
    Process {
        id: brightnessReader
        running: true  // también corre al inicio para valor inicial

        command: [
                    "sh", "-c",
                    // awk lee ambos archivos y calcula el % en una sola pasada
                    "awk 'FNR==1 && NR==1{b=$1} FNR==1 && NR==2{print int(b*100/$1)}'" +
                    " /sys/class/backlight/*/brightness" +
                    " /sys/class/backlight/*/max_brightness"
        ]

        stdout: SplitParser {
            onRead: data => {
                console.log("line:", data)
                const val = parseInt(data)
                // Validación básica para ignorar líneas vacías
                if (!isNaN(val)) {
                    root.brightnessValue = val
                }
            }
        }
    }

    PanelWindow {
        id: osdPanel
        anchors { top: true }
        implicitWidth: 200
        implicitHeight: 40
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.margins { top: 50; left: 800 }
        color: "transparent"

        Rectangle {
            id: osdItem
            property bool mostrar: false
            anchors.fill: parent
            color: "black"
            radius: 6
            opacity: mostrar ? 1.0 : 0.0
            visible: opacity > 0
            enabled: opacity > 0

            // 🔥 Animación suave
            Behavior on opacity {
                NumberAnimation { duration: 400 }
            }


            Timer {
                id: hideTimer
                interval: 3000
                repeat: false
                // running: true
                onTriggered: osdItem.mostrar = false
            }

            Text {
                anchors.centerIn: parent
                text: "Brightness: " + root.brightnessValue + "%"
                color: "white"
                font.pixelSize: 18
            }
        }
    }
}
