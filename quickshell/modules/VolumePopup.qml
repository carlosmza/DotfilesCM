import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.config.theme

ShellRoot {
    id: root

    // 🔊 Estado del volumen
    property real volumeValue: 0
    property int threshold: 80

    // 🏗️ Script de fondo que mantiene actualizado el archivo de volumen
    Process {
        id: volumeUpdater
        running: true

        command: [
            "sh", "-c",
            // 1. Lee volumen y mute iniciales (primer arranque escribe, reinicios no)
            // 2. Bucle: pactl subscribe -> solo cambios en sink -> popup si varió volumen o mute
            "flag=/tmp/volume_osd_initialized; " +
            "if [ ! -f \"$flag\" ]; then " +
            "  old_vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | " +
            "    awk -F'/' '{print $2}' | awk '{print $1}' | tr -d '%'); " +
            "  old_mute=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}'); " +
            "  [ -n \"$old_vol\" ] && echo \"$old_vol\" > /tmp/volume_osd_level; " +
            "  touch \"$flag\"; " +
            "else " +
            "  old_vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | " +
            "    awk -F'/' '{print $2}' | awk '{print $1}' | tr -d '%'); " +
            "  old_mute=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}'); " +
            "fi; " +
            "stdbuf -oL pactl subscribe 2>/dev/null | " +
            "while read -r line; do " +
            "  case \"$line\" in " +
            "    *\"change\"*\"sink \"*) " +
            "      vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | " +
            "        awk -F'/' '{print $2}' | awk '{print $1}' | tr -d '%'); " +
            "      mute=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}'); " +
            "      if [ -n \"$vol\" ] && { [ \"$vol\" != \"$old_vol\" ] || [ \"$mute\" != \"$old_mute\" ]; }; then " +
            "        echo \"$vol\" > /tmp/volume_osd_level; " +
            "        old_vol=\"$vol\"; " +
            "        old_mute=\"$mute\"; " +
            "      fi ;; " +
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
                anchors.rightMargin: Math.min(osdPanel.implicitWidth - root.volumeValue * 3, 305)
                anchors.leftMargin: 5
                anchors.topMargin: 5
                anchors.bottomMargin: 5
                color: Colors.palette.base02
                radius: 6

                Behavior on anchors.rightMargin {
                    NumberAnimation { duration: 200 }
                }

                Text {
                    text: "󰽴"
                    color: root.volumeValue < root.threshold ? Colors.palette.base05 : Colors.palette.base06
                    font.pixelSize: 18
                    x: root.volumeValue < root.threshold ? osdPanel.implicitWidth - 50 : osdPanel.implicitWidth - 100
                    y: 5
                }
            }

            Rectangle {
                id: levelItem
                width: 5
                height: parent.height - 10
                color: Colors.palette.base05
                radius: 6
                x: Math.max(root.volumeValue * 3 - 2, 5)
                y: 5

                Behavior on x {
                    NumberAnimation { duration: 200 }
                }
            }
        }
    }

    Component.onDestruction: {
        volumeUpdater.running = false
        volumeWatcher.running = false
        volumeReader.running = false
    }
}
