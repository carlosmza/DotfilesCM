import QtQuick
import QtQuick.Layouts
import qs.config.theme
import qs.config.fonts

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property int value: -1

    property int duration: 1200

    property bool showing: false

    function show() {
        showing = true
        hideTimer.restart()
    }

    function hide() {
        showing = false
        hideTimer.stop()
    }

    color: Colors.palette.base01
    border.color: "#7F" + Colors.palette.base04.slice(1) // Implementacion de alpha #AARRGGBB
    radius: 8

    opacity: showing ? 1.0 : 0.0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation { duration: 400 }
    }

    Timer {
        id: hideTimer
        interval: root.duration
        repeat: false
        onTriggered: root.showing = false
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: root.icon
            color: Colors.palette.base0D
            font.pixelSize: 14
            font.family: Fonts.varelaRound
            visible: root.icon !== ""
        }

        Text {
            text: root.label
            color: Colors.palette.base05
            font.pixelSize: 14
            font.family: Fonts.varelaRound
        }

        Text {
            text: root.value >= 0 ? root.value + " %" : ""
            color: Colors.palette.base06
            font.pixelSize: 12
            font.weight: Font.Bold
            font.family: Fonts.varelaRound
            visible: root.value >= 0
        }
    }
}
