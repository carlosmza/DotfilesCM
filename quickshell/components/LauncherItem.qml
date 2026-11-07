import Quickshell
import Quickshell.Widgets
import QtQuick
import qs.config.theme
import qs.config.fonts

Item {
    id: root

    required property var entry
    required property string appName
    required property string genericName
    required property string iconName
    property bool selected: false

    signal activated()
    signal hovered()

    height: 46

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: root.selected
            ? Colors.palette.base02
            : (mouse.containsMouse ? Colors.palette.base01 : "transparent")
        border.color: root.activeFocus ? Colors.palette.base04 : "transparent"
        border.width: root.activeFocus ? 1 : 0
        Behavior on color { ColorAnimation { duration: 120 } }

        IconImage {
            id: icon
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            width: 28
            height: 28
            source: Quickshell.iconPath(root.iconName || "application-x-executable")
            asynchronous: true
            mipmap: true
        }

        Column {
            anchors {
                left: icon.right
                leftMargin: 10
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            spacing: 1

            Text {
                width: parent.width
                text: root.appName
                color: Colors.palette.base05
                font.pixelSize: 14
                font.family: Fonts.varelaRound
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: root.genericName
                visible: text !== ""
                color: Colors.palette.base03
                font.pixelSize: 11
                font.family: Fonts.varelaRound
                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.hovered()
            onClicked: root.activated()
        }
    }
}
