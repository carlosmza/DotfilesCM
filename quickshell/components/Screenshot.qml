import Quickshell
import Quickshell.Io
import QtQuick 2.15
import qs.config.theme

Item {
    id: root

    implicitWidth: 32
    implicitHeight: 32

    signal clicked()

    Text {
        anchors.centerIn: parent
        text: ""
        color: Colors.palette.base05
        font.pixelSize: 20
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
