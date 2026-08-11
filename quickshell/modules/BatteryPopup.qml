import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import "../components"
import qs.config.theme

MenuLayout {
    id: root
    title: ""

    readonly property real percentage: Math.max(0, Math.min(100, UPower.displayDevice?.percentage * 100 || 0))
    readonly property bool isCharging: UPower.onBattery === false
    property string currentProfile: ""

    property var profiles: [
        { name: "power-saver", label: "Power Saver", icon: "" },
        { name: "balanced", label: "Balanced", icon: "" },
        { name: "performance", label: "Performance", icon: "" }
    ]

    onVisibleChanged: {
        if (visible) getProfileProc.running = true
    }

    Process {
        id: getProfileProc
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.currentProfile = this.text.trim()
            }
        }
    }

    Process {
        id: setProfileProc
        onRunningChanged: {
            if (!running && root.visible) getProfileProc.running = true
        }
    }

    Row {
        spacing: 8
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            text: ""
            color: Colors.palette.base05
            font.pixelSize: 20
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: Math.round(root.percentage) + "%"
            color: Colors.palette.base05
            font.pixelSize: 16
            font.weight: Font.Bold
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: {
            if (root.percentage >= 100) return "Full"
            if (root.isCharging) return "Charging"
            return "On Battery"
        }
        color: Colors.palette.base03
        font.pixelSize: 13
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Colors.palette.base03
    }

    Text {
        text: "POWER PROFILE"
        color: Colors.palette.base03
        font.pixelSize: 11
        font.weight: Font.Bold
    }

    Repeater {
        model: root.profiles

        delegate: Rectangle {
            border.color: Colors.palette.base01
            border.width: 1
            width: parent.width
            height: 32
            radius: 8
            color: modelData.name === root.currentProfile
                ? Colors.palette.base02
                : (ma.containsMouse ? Colors.palette.base01 : "transparent")

            Behavior on color { ColorAnimation { duration: 150 } }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: modelData.icon
                    color: Colors.palette.base05
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: modelData.label
                    color: Colors.palette.base05
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (modelData.name !== root.currentProfile) {
                        setProfileProc.command = ["powerprofilesctl", "set", modelData.name]
                        setProfileProc.running = true
                    }
                }
            }
        }
    }
}
