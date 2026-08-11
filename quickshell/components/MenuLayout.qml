import QtQuick
import QtQuick.Layouts
import qs.config.theme

Rectangle {
    id: root
    anchors.fill: parent
    color: Colors.palette.base00
    border.color: Colors.palette.base02
    border.width: 2
    radius: 15
    clip: true
    focus: true

    property string title: ""
    property string titleIcon: ""
    property string statusText: ""
    property color statusColor: Colors.palette.base03

    default property alias content: layout.data
    property alias overlay: overlaySlot.data

    signal closeRequested()
    Keys.onEscapePressed: root.closeRequested()

    Column {
        id: layout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 6

        RowLayout {
            width: parent.width
            spacing: 8
            visible: root.title !== ""

            Text {
                text: root.titleIcon
                color: Colors.palette.base05
                font.pixelSize: 15
                visible: root.titleIcon !== ""
            }

            Text {
                text: root.title
                color: Colors.palette.base05
                font.pixelSize: 15
                font.weight: Font.Bold
            }

            Item { Layout.fillWidth: true; visible: root.statusText !== "" }

            Text {
                text: root.statusText
                color: root.statusColor
                font.pixelSize: 12
                visible: root.statusText !== ""
            }
        }
    }

    Item {
        id: overlaySlot
        anchors { top: parent.top; left: parent.left; right: parent.right }
        z: 30
    }
}
