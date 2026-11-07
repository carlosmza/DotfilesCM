pragma ComponentBehavior: Bound

import Quickshell.Io
import QtQuick
import "../components"
import qs.config.theme

MenuLayout {
    id: root

    readonly property string screenshotDirectory: "/home/carlosm/Pictures/Screenshots"
    property bool hypridleActive: true

    property var toolsItems: [
        { icon: "", label: "Area", action: () => root.takeShot("region") },
        { icon: "", label: "Fullscreen", action: () => root.takeShot("output") },
        { icon: "", label: "Theme Selector", action: () => root.toggleThemeSelector() },
        { icon: "", label: "Wallpaper Selector", action: () => root.toggleWallpaperSelector() }
    ]

    Process { id: shotProc }
    Process { id: toggleTheme }
    Process { id: toggleWp }
    Process {
        id: hypridleCheck
        command: ["systemctl", "--user", "is-active", "hypridle"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var status = this.text.trim()
                if (status === "active")
                    root.hypridleActive = true
                else if (status === "inactive")
                    root.hypridleActive = false
            }
        }
    }
    Process { id: hypridleProc }

    function takeShot(mode) {
        const now = new Date();
        const pad = (n) => n.toString().padStart(2, '0');
        const ts = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}_${pad(now.getHours())}-${pad(now.getMinutes())}-${pad(now.getSeconds())}`;
        const filename = `Screenshot-From-${ts}.png`;

        shotProc.command = ["hyprshot", "-m", mode, "-o", root.screenshotDirectory, "-f", filename];
        shotProc.startDetached();
        root.closeRequested();
    }

    function toggleThemeSelector() {
        toggleTheme.command = ["quickshell", "ipc", "call", "theme", "toggle"]
        toggleTheme.startDetached()
        root.closeRequested()
    }

    function toggleWallpaperSelector() {
        toggleWp.command = ["quickshell", "ipc", "call", "wallpapers", "toggle"]
        toggleWp.startDetached()
        root.closeRequested()
    }

    function toggleHypridle() {
        hypridleProc.command = ["systemctl", "--user", hypridleActive ? "stop" : "start", "hypridle"];
        hypridleProc.startDetached();
        hypridleActive = !hypridleActive;
    }

    Repeater {
        model: root.toolsItems

        delegate: Rectangle {
            id: item

            required property var modelData

            width: parent.width
            implicitHeight: 32
            radius: 8
            border.color: Colors.palette.base01
            border.width: 1
            color: "transparent"

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: item.modelData.icon
                    color: Colors.palette.base05
                    font.pixelSize: 14
                    textFormat: Text.PlainText
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: item.modelData.label
                    color: Colors.palette.base05
                    font.pixelSize: 13
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: item.modelData.action()
            }
        }
    }

    Rectangle {
        width: parent.width
        implicitHeight: 32
        radius: 8
        border.color: Colors.palette.base01
        border.width: 1
        color: "transparent"

        Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 76
            spacing: 8

            Text {
                text: root.hypridleActive ? "󱩎" : "󰹐"
                color: root.hypridleActive ? Colors.palette.base03 : Colors.palette.base0B
                font.pixelSize: 14
                textFormat: Text.PlainText
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Caffeine"
                color: Colors.palette.base05
                font.pixelSize: 13
                textFormat: Text.PlainText
                elide: Text.ElideRight
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 36
            height: 16
            radius: 3
            color: Colors.palette.base01

            Rectangle {
                id: fill
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width * (root.hypridleActive ? 0 : 1)
                height: parent.height
                radius: parent.radius
                color: Colors.palette.base0D

                Behavior on width {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }
            }

            Rectangle {
                width: 20
                height: 20
                radius: 30
                color: Colors.palette.base07
                border.color: Colors.palette.base01
                border.width: 1
                x: fill.width - 6
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleHypridle()
        }
    }
}
