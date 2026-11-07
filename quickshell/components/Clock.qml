import Quickshell
import QtQuick
import "js/TimeShared.js" as TimeShared
import qs.config.theme
import qs.config.fonts

Item {
    id: root

    readonly property date now: TimeShared.mexicoCityDate(clock.date)
    property string font: Fonts.varelaRound

    implicitWidth: 40
    implicitHeight: 64

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Column {
        anchors.centerIn: parent
        width: parent.width
        spacing: 2

        Text {
            width: parent.width
            text: Qt.formatTime(root.now, "hh")
            color: Colors.palette.base06
            font {
                pixelSize: 20
                bold: false
                family: root.font
            }
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            width: parent.width
            text: Qt.formatTime(root.now, "mm")
            color: Colors.palette.base06
            font {
                pixelSize: 20
                bold: false
                family: root.font
            }
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            width: parent.width
            text: Qt.formatTime(root.now, "ss")
            color: Colors.palette.base04
            font {
                pixelSize: 19
                bold: false
                family: root.font
            }
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
