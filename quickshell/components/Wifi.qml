import QtQuick
import Quickshell.Io
import qs.config.theme
import "js/WifiShared.js" as WifiShared

Item {
    id: root

    property bool connected: false
    property int strength: 0
    property string ssid: ""

    implicitWidth: 30
    implicitHeight: 10

    readonly property string icon: WifiShared.iconFor(root.connected, root.strength)
    readonly property color iconColor: root.connected
        ? (root.strength <= 20 ? Colors.palette.base08 : Colors.palette.base06)
        : Colors.palette.base03

    Process {
        id: nmcliProc
        command: WifiShared.queryCommand
        running: true

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
        interval: 1000
        running: true
        repeat: true
        onTriggered: nmcliProc.running = true
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.iconColor
        font.pixelSize: 20
    }
}
