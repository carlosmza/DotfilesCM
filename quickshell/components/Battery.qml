import QtQuick
import Quickshell.Services.UPower
import qs.config.theme

Item {
    id: root

    readonly property real capacity: (UPower.displayDevice?.percentage ?? 0) * 100
    readonly property bool isCharging: !UPower.onBattery

    implicitWidth: 31
    implicitHeight: 50

    readonly property var icons: ["󰂃","󰁺","󰁻","󰁼","󰁽","󰁾","󰁿","󰂀","󰂁","󰂂","󰁹"]

    readonly property string icon: {
        var lvl = Math.max(0, Math.min(100, Math.floor(capacity)))
        var idx = Math.min(icons.length - 1, Math.floor(lvl * icons.length / 100))
        return icons[idx]
    }

    readonly property color iconColor: {
        if (isCharging)
            return capacity >= 99 ? Colors.palette.base0B : Colors.palette.base0D
        if (capacity <= 20)
            return Colors.palette.base08
        return Colors.palette.base06
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.iconColor
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
    }
}
