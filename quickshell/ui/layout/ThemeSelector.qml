import Quickshell
import Quickshell.Io
import QtQuick
import qs.config.theme

PanelWindow {
    id: root
    visible: false
    color: "black"
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    aboveWindows: true

    // Keys.onReturnPressed: {
    //     if (selectedIndex >= 0 && selectedIndex < themes.length) {
    //         root.applyTheme(themes[selectedIndex])
    //         root.visible = false
    //     }
    // }

    property var themes: []
    property int selectedIndex: -1

    Component.onCompleted: {
        loadThemes()
    }

    onSelectedIndexChanged: {
        themeList.currentIndex = selectedIndex
        themeList.positionViewAtIndex(selectedIndex, ListView.Center)
    }

    function loadThemes() {
        procList.command = ["bash", "-c", "ls /home/carlosm/.config/system-themes/themes/*.json 2>/dev/null | xargs -n1 basename | grep -v '^current\\.json$'"]
        procList.running = true
    }

    function parseThemes(output) {
        var lines = output.trim().split("\n")
        var files = []
        for (var i = 0; i < lines.length; i++) {
            var f = lines[i].trim()
            if (f.endsWith(".json") && f !== "current.json") {
                var name = f.replace(".json", "")
                files.push(name)
            }
        }
        files.sort()
        themes = files
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

    // Rectangle {
    //     anchors.fill: parent
    //     color: "transparent"
    //
    //     MouseArea {
    //         anchors.fill: parent
    //         onClicked: root.visible = false
    //     }
    // }

    Rectangle {
        id: container
        width: 220
        height: 320
        radius: 16
        color: Colors.palette.base00
        border.color: Colors.palette.base0D
        border.width: 2
        anchors.centerIn: parent

        Column {
            anchors.fill: parent
            anchors.margins: 12

            Text {
                text: "Themes"
                color: Colors.palette.base05
                font.pixelSize: 18
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            ListView {
                id: themeList
                width: parent.width
                height: parent.height - 40
                clip: true
                model: themes
                currentIndex: selectedIndex

                delegate: Rectangle {
                    width: parent.width
                    height: 32
                    radius: 6
                     // Color de fondo según estado: hover, seleccionado o normal
                    color: {
                        if (itemMouse.containsMouse)
                            return Colors.palette.base03          // color al pasar el cursor
                        else if (index === selectedIndex)
                            return Colors.palette.base0D          // color cuando está seleccionado
                        else
                            return Colors.palette.base02          // color normal
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        spacing: 8

                        // Círculo con dos mitades de color
                        Rectangle {
                            width: 24; height: 24
                            radius: 12
                            color: "transparent"
                            clip: true
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: 12; height: 24
                                anchors.left: parent.left
                                color: modelData.variant || "#888888"   // fallback si falta
                            }
                            Rectangle {
                                width: 12; height: 24
                                anchors.right: parent.right
                                color: modelData.base0D || "#888888"
                            }
                        }

                        Text {
                            // text: modelData.name
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 13
                            color: "white"
                            // color: (itemMouse.containsMouse || index === selectedIndex)
                            //        ? Colors.palette.base00 : Colors.palette.base05
                        }
                    }
                    // Text {
                    //     text: modelData
                    //             // Color del texto: claro sobre fondo oscuro, oscuro sobre fondo claro
                    //     color: (itemMouse.containsMouse || index === selectedIndex)
                    //            ? Colors.palette.base00 : Colors.palette.base05
                    //     font.pixelSize: 13
                    //     anchors.centerIn: parent
                    // }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            selectedIndex = index
                            root.applyTheme(modelData)
                            root.visible = false
                        }
                    }
                }
            }
        }
    }
}
