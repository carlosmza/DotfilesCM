import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.config.theme

ShellRoot {
    id: root

    // 🔊 Estado del volumen
    property real volumeValue: 0

    // 🏗️ Script de fondo que mantiene actualizado el archivo de volumen
    Process {
        id: volumeUpdater
        running: true

        command: [
            "sh", "-c",
            // 1. Crea el archivo con el volumen inicial
            // 2. Bucle: pactl subscribe -> cada cambio de sink -> actualiza archivo
            "pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | " +
            "awk -F'/' '{print $2}' | awk '{print $1}' | tr -d '%' > /tmp/volume_osd_level; " +
            "stdbuf -oL pactl subscribe 2>/dev/null | " +
            "while read -r line; do " +
            "  case \"$line\" in " +
            "    *\"change\"*\"sink\"*) " +
            "      pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | " +
            "      awk -F'/' '{print $2}' | awk '{print $1}' | tr -d '%' > /tmp/volume_osd_level ;; " +
            "  esac; " +
            "done"
        ]
    }

    // 👁️ Watcher: se activa cuando el archivo de volumen cambia
    Process {
        id: volumeWatcher
        running: true

        command: [
            "sh", "-c",
            // Nos aseguramos de que el archivo exista antes de empezar a vigilarlo
            "[ -f /tmp/volume_osd_level ] || echo '0' > /tmp/volume_osd_level; " +
            "inotifywait -m -e modify /tmp/volume_osd_level 2>/dev/null"
        ]

        stdout: SplitParser {
            onRead: data => {
                osdItem.mostrar = true
                hideTimer.restart()
                volumeReader.running = true
            }
        }
    }

    // 📖 Lector: toma el valor actual desde el archivo
    Process {
        id: volumeReader
        running: false  // solo se lanza bajo demanda

        command: [
            "sh", "-c",
            "cat /tmp/volume_osd_level 2>/dev/null || echo 0"
        ]

        stdout: SplitParser {
            onRead: data => {
                const val = parseInt(data)
                if (!isNaN(val)) {
                    root.volumeValue = val
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
            color: Colors.palette.base01
            radius: 6
            opacity: mostrar ? 1.0 : 0.0
            visible: opacity > 0
            enabled: opacity > 0

            Behavior on opacity {
                NumberAnimation { duration: 400 }
            }

            Timer {
                id: hideTimer
                interval: 1200
                repeat: false
                onTriggered: osdItem.mostrar = false
            }

            Text {
                anchors.centerIn: parent
                text: "Volume: " + root.volumeValue + "%"
                color: Colors.palette.base06
                font.pixelSize: 18
            }
        }
    }
}
