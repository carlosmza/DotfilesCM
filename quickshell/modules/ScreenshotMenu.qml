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

    property string font: Fonts.varelaRound

    function takeShot(mode) {
        shotProc.command = ["bash", "-c", "hyprshot -m " + mode]
        shotProc.running = true
    }

    Process {
        id: shotProc
        command: ["bash"]
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 6

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: ""
                color: Colors.palette.base0D
                font.pixelSize: 20
            }

            Text {
                text: "Screenshot"
                color: Colors.palette.base05
                font.pixelSize: 15
                font.weight: Font.Bold
                font.family: root.font
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colors.palette.base03
        }

        // Area button
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
                    text: ""
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
                onClicked: root.takeShot("region")
            }
        }

        // Fullscreen button
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
                    text: ""
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
                onClicked: root.takeShot("output")
            }
        }
    }
}
