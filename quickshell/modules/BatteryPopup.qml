import Quickshell
import Quickshell.Services.UPower
import QtQuick
import qs.config.theme

Rectangle {
    anchors.fill: parent
    color: Colors.palette.base00
    radius: 12

    Rectangle {
        id: batteryBody
        width: 50
        height: 24
        radius: 4
        border.color: Colors.palette.base05
        border.width: 2
        anchors.centerIn: parent

        Rectangle {
            id: batteryLevel
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                margins: 3
            }
            width: parent.width * (percentage / 100)
            radius: 2
            color: levelColor
        }

        Rectangle {
            id: batteryTip
            width: 4
            height: 10
            radius: 1
            anchors {
                left: parent.right
                top: parent.top
                bottom: parent.bottom
                topMargin: 5
                bottomMargin: 5
            }
            color: Colors.palette.base05
        }
    }

    Column {
        anchors {
            left: batteryBody.right
            leftMargin: 12
            verticalCenter: parent.verticalCenter
        }

        Text {
            text: percentage + "%"
            color: Colors.palette.base05
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }

        Text {
            text: statusText
            color: Colors.palette.base03
            font.pixelSize: 10
        }
    }

    readonly property real percentage: Math.max(0, Math.min(100, UPower.displayDevice?.percentage * 100 || 0))

    readonly property bool isCharging: UPower.onBattery === false

    readonly property string statusText: {
        if (percentage >= 100) return "Full"
        if (isCharging) return "Charging"
        return "On Battery"
    }

    readonly property color levelColor: {
        if (percentage >= 99 && isCharging) return Colors.palette.base0B
        if (percentage <= 20) return Colors.palette.base08
        return Colors.palette.base0D
    }
}