import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    visible: false

    property real volumeValue: 0
    property int threshold: 80

    signal valueChanged()

    Process {
        id: volumeUpdater
        running: true

        command: [
            "sh", "-c",
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

    Process {
        id: volumeWatcher
        running: true

        command: [
            "sh", "-c",
            "[ -f /tmp/volume_osd_level ] || echo '0' > /tmp/volume_osd_level; " +
            "inotifywait -m -e modify /tmp/volume_osd_level 2>/dev/null"
        ]

        stdout: SplitParser {
            onRead: data => {
                volumeReader.running = true
                root.valueChanged()
            }
        }
    }

    Process {
        id: volumeReader
        running: false

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

    Component.onDestruction: {
        volumeUpdater.running = false
        volumeWatcher.running = false
        volumeReader.running = false
    }
}
