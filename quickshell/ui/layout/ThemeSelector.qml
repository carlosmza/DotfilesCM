import Quickshell
import Quickshell.Io
import QtQuick
import qs.config.theme
import qs.config.fonts

PanelWindow {
    id: root
    anchors {
        right: true
    }

    margins {
        left: 10
        right: 10
    }

    implicitWidth: 230
    implicitHeight: Math.min(Math.max(themes.length * 50 + 8, 200), 600)
    color: "transparent"
    exclusiveZone: -1
    visible: false
    focusable: true

    onVisibleChanged: {
        if (visible) {
            root.applying = false
            if (themes.length === 0) loadThemes()
            themeContent.forceActiveFocus()
        }
    }

    property var themes: []
    property int selectedIndex: -1
    property string font: Fonts.varelaRound
    property int fontSize: 14
    property bool applying: false

    Component.onCompleted: loadThemes()

    onSelectedIndexChanged: {
        themeList.currentIndex = selectedIndex
        themeList.positionViewAtIndex(selectedIndex, ListView.Center)
    }

    function loadThemes() {
        procList.command = ["bash", "-c",
        "for f in /home/carlosm/.config/system-themes/themes/*.json; do
            name=$(basename \"$f\" .json);
            [ \"$name\" = \"current\" ] && continue;
            c0=$(jq -r '.palette.base00' \"$f\");
            cD=$(jq -r '.palette.base0D' \"$f\");
            cF=$(jq -r '.palette.base0F' \"$f\");
            echo \"$name|$c0|$cD|$cF\";
        done"]
        procList.running = true
    }

    function parseThemes(output) {
        var lines = output.trim().split("\n")
        var items = []
        for (var i = 0; i < lines.length; i++) {
            var parts = lines[i].trim().split("|")
            if (parts.length >= 4) {
                items.push({
                    name: parts[0],
                    base00: parts[1],
                    base0D: parts[2],
                    base0F: parts[3]
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
        if (root.applying) return
        root.applying = true
        proc.command = [
            "bash", "-c",
            `/home/carlosm/.config/scripts/themes/apply-theme.sh "${name}" >> /tmp/apply-theme.log 2>&1`
        ]
        proc.running = true
    }

    Process {
        id: proc
        command: ["bash"]
        onRunningChanged: {
            if (!running && root.applying) {
                root.applying = false
                root.visible = false
            }
        }
    }

    Rectangle {
        id: themeContent
        color: Colors.palette.base00
        anchors.fill: parent
        radius: 20
        clip: false
        focus: true
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                if (root.applying) return
                root.visible = false
                event.accepted = true
            } else if (event.key === Qt.Key_Up) {
                if (selectedIndex > 0)
                    selectedIndex--
                else
                    selectedIndex = themes.length - 1   // ciclo hacia el final
                event.accepted = true
            } else if (event.key === Qt.Key_Down) {
                if (selectedIndex < themes.length - 1)
                    selectedIndex++
                else
                    selectedIndex = 0                   // ciclo hacia el inicio
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (!root.applying && selectedIndex >= 0 && selectedIndex < themes.length) {
                    root.applyTheme(themes[selectedIndex].name)
                }
                event.accepted = true
            } else if (event.key === Qt.Key_F5) {
                loadThemes()
                event.accepted = true
            }
        }

        ListView {
            id: themeList
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 8
            }
            spacing: 6
            clip: false
            model: themes
            currentIndex: selectedIndex
            interactive: !root.applying

            delegate: Rectangle {
                width: themeList.width
                height: 44
                radius: 10
                enabled: !root.applying
                opacity: enabled ? 1.0 : 0.5
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
                        id: squareColor
                        width: 28
                        height: 28
                        radius: 0
                        clip: true
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            id: leftSquare
                            width: parent.width / 2
                            height: parent.height
                            color: modelData.base00
                        }

                        Rectangle {
                            id: rightTopSquare
                            width: parent.width / 2
                            height: parent.height / 2
                            x: parent.width / 2
                            color: modelData.base0D
                        }

                        Rectangle {
                            id: rightBottomSquare
                            width: parent.width / 2
                            height: parent.height
                            x: parent.width / 2
                            y: parent.height / 2
                            color: modelData.base0F
                        }

                        Rectangle {
                            id: borderSquare
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
                            pixelSize: root.fontSize
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
                        if (root.applying) return
                        selectedIndex = index
                        root.applyTheme(modelData.name)
                    }
                }

                Behavior on scale {
                    NumberAnimation { duration: 100 }
                }
                scale: mouseArea.containsMouse ? 1.06 : 1.0
            }
        }

        Text {
            anchors.centerIn: parent
            text: "No themes found\nPress F5 to reload"
            color: Colors.palette.base03
            horizontalAlignment: Text.AlignHCenter
            visible: themes.length === 0 && !root.applying
            font {
                pixelSize: root.fontSize
                family: root.font
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 20
            color: Qt.rgba(0, 0, 0, 0.5)
            visible: root.applying
            z: 100

            Text {
                anchors.centerIn: parent
                text: "Applying\u2026"
                color: Colors.palette.base05
                font {
                    pixelSize: root.fontSize + 2
                    family: root.font
                }
            }
        }
    }
}
