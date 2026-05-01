import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // 🔹 API del componente
    property int level: 0
    property string status: "Unknown"

    // 🔹 tamaño implícito (IMPORTANTE)
    implicitWidth: 30
    implicitHeight: 100

    // 🔹 ICONO derivado (lógica separada)
    property string icon: {
        var icons = ["󰂃","󰁺","󰁻","󰁼","󰁽","󰁾","󰁿","󰂀","󰂁","󰂂","󰁹"]
        var lvl = Math.max(0, Math.min(100, parseInt(level)))
        var n = icons.length
        var idx = Math.min(n - 1, Math.floor(lvl * n / 100))
        return icons[idx]
    }

    property string icon_color: {
        if (level <= 99 & status === "Charging") return "blue"
        if (status === "Charging") return "#00ff00" // verde para cargando
        if (level <= 20) return "#ff0000" // rojo para batería baja
        return "white" // blanco para niveles normales
    }

    // 🔹 LECTURA de batería (datos)
    Process {
        id: batteryLevelProc
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.level = parseInt(this.text.trim())
        }
    }

    Process {
        id: batteryStatusProc
        command: ["cat", "/sys/class/power_supply/BAT0/status"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.status = this.text.trim()
        }
    }

    // 🔹 TIMER (actualización)
    Timer {
        interval: 5000   // cada 5s (más eficiente)
        running: true
        repeat: true

        onTriggered: {
            batteryLevelProc.running = true
            batteryStatusProc.running = true
        }
    }

    // 🔹 UI (presentación)
    Text {
        anchors.centerIn: parent
        // text: root.icon + " " + root.level + "%"
        text: root.icon
        color: root.icon_color
        font.pixelSize: 18
        horizontalAlignment: Text.AlignHCenter
    }
}
