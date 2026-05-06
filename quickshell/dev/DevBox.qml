import QtQuick
import QtQuick.Window
import qs.config.theme

Window {
    visible: true
    width: 200
    height: 200

    Rectangle {
        anchors.fill: parent
        color: Colors.palette.base09
        // color: "white"
        Text {
            text: Colors.name
            color: Colors.palette.base00
        }
    }
}

