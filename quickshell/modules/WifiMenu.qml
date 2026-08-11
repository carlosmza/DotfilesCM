import Quickshell
import QtQuick
import qs.config.theme

Rectangle {
    anchors.fill: parent
    color: Colors.palette.base00
    radius: 15
    // border {
    //     color: Colors.palette.base05
    //     width: 1
    // }

    Text {
        anchors.centerIn: parent
        text: "wifi"
        color: Colors.palette.base05
    }
}
