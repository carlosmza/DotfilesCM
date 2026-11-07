import Quickshell.Io
import QtQuick
import "../components"
import "../components/js/WifiShared.js" as WifiShared
import qs.config.theme

MenuLayout {
    id: root

    property bool connected: false
    property string ssid: ""
    property int strength: 0

    readonly property string icon: WifiShared.iconFor(root.connected, root.strength)
    readonly property color iconColor: root.connected
        ? (root.strength <= 20 ? Colors.palette.base08 : Colors.palette.base06)
        : Colors.palette.base03

    Process {
        id: infoProc
        command: WifiShared.queryCommand
        stdout: StdioCollector {
            onStreamFinished: {
                var info = WifiShared.parse(this.text)
                root.connected = info.connected
                root.ssid = info.ssid
                root.strength = info.strength
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: infoProc.running = true
    }

    Component.onCompleted: infoProc.running = true

    Row {
        spacing: 8
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            text: root.icon
            color: root.iconColor
            font.pixelSize: 24
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.connected ? root.ssid : "Not connected"
            color: root.connected ? Colors.palette.base05 : Colors.palette.base03
            font.pixelSize: 13
            font.weight: Font.Bold
            font.italic: !root.connected
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MenuSeparator {}

    Rectangle {
        width: parent.width
        height: 6
        radius: 3
        color: Colors.palette.base01

        Rectangle {
            height: parent.height
            radius: 3
            color: root.connected ? Colors.palette.base0D : Colors.palette.base03
            width: parent.width * (root.strength / 100)
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.connected ? root.strength + "% — Connected" : "No connection"
        color: Colors.palette.base04
        font.pixelSize: 12
    }
}
