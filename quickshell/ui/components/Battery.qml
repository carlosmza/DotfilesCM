import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io
import qs.config.theme

Item {
    id: root

    readonly property real capacity: (UPower.displayDevice?.percentage ?? 0) * 100
    readonly property bool status: !UPower.onBattery

    implicitWidth: 31
    implicitHeight: 100

    property string icon: {
        var icons = ["󰂃","󰁺","󰁻","󰁼","󰁽","󰁾","󰁿","󰂀","󰂁","󰂂","󰁹"]
        var lvl = Math.max(0, Math.min(100, parseInt(capacity)))
        var n = icons.length
        var idx = Math.min(n - 1, Math.floor(lvl * n / 100))
        return icons[idx]
    }

    property string icon_color: {
        if (capacity >= 99 && status === true) return "#00ff00" // verde para cargando
        if (capacity < 99 && status === true) return "blue"
        if (capacity <= 20) return "#ff0000" // rojo para batería baja
        return Colors.palette.base06 // blanco para niveles normales
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.icon_color
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
    }
}
