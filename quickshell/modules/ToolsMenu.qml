import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.config.theme
import qs.config.fonts

Rectangle {
    id: root
    anchors.fill: parent
    color: Colors.palette.base00
    radius: 15
    clip: true
    focus: true
    Keys.onEscapePressed: root.closeRequested()

    property string font: Fonts.varelaRound

    signal closeRequested()

    function takeShot(mode) {
        shotProc.command = ["bash", "-c", "hyprshot -m " + mode]
        shotProc.running = true
    }

    function toggleThemeSelector() {
        toggleTheme.command = ["quickshell", "ipc", "call", "theme", "toggle"]
        toggleTheme.running = true
    }

    function toggleWallpaperSelector() {
        toggleWp.command = ["quickshell", "ipc", "call", "wallpapers", "toggle"]
        toggleWp.running = true
    }

    Process { id: shotProc; command: ["bash"] }
    Process { id: toggleTheme; command: ["bash"] }
    Process { id: toggleWp; command: ["bash"] }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 6

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Tools"
                color: Colors.palette.base05
                font.pixelSize: 15
                font.weight: Font.Bold
                font.family: root.font
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colors.palette.base03
        }

        // Area
        Rectangle {
            Layout.fillWidth: true
            height: 36
            radius: 8
            color: areaMa.containsMouse ? Colors.palette.base03 : Colors.palette.base02

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: ""
                    color: Colors.palette.base0D
                    font.pixelSize: 16
                }

                Text {
                    text: "Area"
                    color: Colors.palette.base05
                    font.pixelSize: 13
                    font.family: root.font
                }

                Item { Layout.fillWidth: true }
            }

            MouseArea {
                id: areaMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.takeShot("region")
                    root.closeRequested()
                }
            }
        }

        // Fullscreen
        Rectangle {
            Layout.fillWidth: true
            height: 36
            radius: 8
            color: fullMa.containsMouse ? Colors.palette.base03 : Colors.palette.base02

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: ""
                    color: Colors.palette.base0D
                    font.pixelSize: 16
                }

                Text {
                    text: "Fullscreen"
                    color: Colors.palette.base05
                    font.pixelSize: 13
                    font.family: root.font
                }

                Item { Layout.fillWidth: true }
            }

            MouseArea {
                id: fullMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.takeShot("output")
                    root.closeRequested()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colors.palette.base03
            Layout.topMargin: 4
        }

        // Theme Selector
        Rectangle {
            Layout.fillWidth: true
            height: 36
            radius: 8
            color: themeMa.containsMouse ? Colors.palette.base03 : Colors.palette.base02

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: ""
                    color: Colors.palette.base0D
                    font.pixelSize: 16
                }

                Text {
                    text: "Theme Selector"
                    color: Colors.palette.base05
                    font.pixelSize: 13
                    font.family: root.font
                }

                Item { Layout.fillWidth: true }
            }

            MouseArea {
                id: themeMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.toggleThemeSelector()
                    root.closeRequested()
                }
            }
        }

        // Wallpaper Selector
        Rectangle {
            Layout.fillWidth: true
            height: 36
            radius: 8
            color: wpMa.containsMouse ? Colors.palette.base03 : Colors.palette.base02

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: ""
                    color: Colors.palette.base0D
                    font.pixelSize: 16
                }

                Text {
                    text: "Wallpaper Selector"
                    color: Colors.palette.base05
                    font.pixelSize: 13
                    font.family: root.font
                }

                Item { Layout.fillWidth: true }
            }

            MouseArea {
                id: wpMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.toggleWallpaperSelector()
                    root.closeRequested()
                }
            }
        }
    }
}
