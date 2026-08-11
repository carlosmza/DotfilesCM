import QtQuick
import qs.config.theme

Item {
    id: root
    implicitWidth: 160
    implicitHeight: 36

    property string iconText: ""
    property string label: ""
    property color iconColor: Colors.palette.base0D

    signal clicked()

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 8
        color: ma.containsMouse ? Colors.palette.base03 : Colors.palette.base02
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    Text {
        id: iconT
        text: root.iconText
        color: root.iconColor
        font.pixelSize: 16
        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
    }

    Text {
        id: labelT
        text: root.label
        color: Colors.palette.base05
        font.pixelSize: 13
        anchors { left: iconT.right; leftMargin: 8; verticalCenter: parent.verticalCenter }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
