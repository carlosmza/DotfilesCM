import Quickshell
import Quickshell.Io
import QtQuick
import qs.config.theme
import qs.config.fonts

PanelWindow {
    id: root
    anchors {
        top: true
        right: true
        bottom: true
    }

    margins {
        left: 10
        top: 10
        bottom: 10
        right: 10
    }

    implicitWidth: 240
    color: "transparent"
    exclusiveZone: -1
    visible: false

    property var themes: []
    property int selectedIndex: -1
    property string font: Fonts.varelaRound

    Component.onCompleted: loadThemes()

    onSelectedIndexChanged: {
        themeList.currentIndex = selectedIndex
        themeList.positionViewAtIndex(selectedIndex, ListView.Center)
    }

    function loadThemes() {
        procList.command = ["bash", "-c", "for f in /home/carlosm/.config/system-themes/themes/*.json; do name=$(basename \"$f\" .json); [ \"$name\" = \"current\" ] && continue; c0=$(jq -r '.palette.base00' \"$f\"); cD=$(jq -r '.palette.base0D' \"$f\"); echo \"$name|$c0|$cD\"; done"]
        procList.running = true
    }

    function parseThemes(output) {
        var lines = output.trim().split("\n")
        var items = []
        for (var i = 0; i < lines.length; i++) {
            var parts = lines[i].trim().split("|")
            if (parts.length >= 3) {
                items.push({
                    name: parts[0],
                    base00: parts[1],
                    base0D: parts[2]
                })
            }
        }
        items.sort(function(a, b) { return a.name < b.name ? -1 : 1 })
        themes = items
    }

    Process {
        id: procList
        command: ["bash"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseThemes(this.text)
            }
        }
    }

    function applyTheme(name) {
        proc.command = ["/home/carlosm/.config/scripts/themes/apply-theme.sh", name]
        proc.running = true
    }

    Process {
        id: proc
        command: ["bash"]
    }

    Rectangle {
        color: Colors.palette.base00
        anchors.fill: parent
        radius: 20
        clip: false

        Text {
            text: "Themes"
            color: Colors.palette.base05
            font.pixelSize: 16
            font.weight: Font.Bold
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: 12
            }
        }

        ListView {
            id: themeList
            anchors {
                top: parent.top
                topMargin: 40
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 8
            }
            spacing: 6
            clip: true
            model: themes
            currentIndex: selectedIndex

            delegate: Rectangle {
                width: themeList.width - 16
                height: 44
                radius: 10
                color: {
                    if (mouseArea.containsMouse)
                        return Colors.palette.base03
                    if (index === selectedIndex)
                        return Colors.palette.base0D
                    return Colors.palette.base02
                }

                Row {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 8
                        rightMargin: 8
                    }
                    spacing: 10

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        clip: true
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            width: parent.width / 2
                            height: parent.height
                            color: modelData.base00
                        }

                        Rectangle {
                            width: parent.width / 2
                            height: parent.height
                            x: parent.width / 2
                            color: modelData.base0D
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: {
                                if (mouseArea.containsMouse || index === selectedIndex)
                                    return Colors.palette.base00
                                return Colors.palette.base03
                            }
                            border.width: 1
                        }
                    }

                    Text {
                        text: modelData.name
                        anchors.verticalCenter: parent.verticalCenter
                        color: {
                            if (mouseArea.containsMouse || index === selectedIndex)
                                return Colors.palette.base00
                            return Colors.palette.base05
                        }
                        font {
                            pixelSize: 13
                            family: root.font
                        }
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        selectedIndex = index
                        root.applyTheme(modelData.name)
                        root.visible = false
                    }
                }

                Behavior on scale {
                    NumberAnimation { duration: 100 }
                }
                scale: mouseArea.containsMouse ? 1.06 : 1.0
            }
        }
    }
}
