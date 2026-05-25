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

    //Keys.onEscapePressed: root.visible = false

    property var wallpapers: []
    property string font: Fonts.varelaRound

    Component.onCompleted: loadWallpapers()

    function loadWallpapers() {
        procList.command = ["bash", "-c", "ls /home/carlosm/Pictures/wallpaper_thumbs/thumb-*.{jpg,jpeg,png,JPG,JPEG,PNG} 2>/dev/null | xargs -n1 basename"]
        procList.running = true
    }

    function parseWallpapers(output) {
        var lines = output.trim().split("\n")
        var files = []
        for (var i = 0; i < lines.length; i++) {
            var f = lines[i].trim()
            if (f === "") continue
            files.push(f)
        }
        files.sort()
        wallpapers = files
    }

    function wallpaperFromThumb(thumbName) {
        // "thumb-Chine-Dark.jpeg" -> "Chine-Dark.jpeg"
        var name = thumbName.replace(/^thumb-/, "")
        return "/home/carlosm/Pictures/Wallpapers/" + name
    }

    function thumbPath(thumbName) {
        return "/home/carlosm/Pictures/wallpaper_thumbs/" + thumbName
    }

    function applyWallpaper(thumbName) {
        var wp = wallpaperFromThumb(thumbName)
        procApply.command = ["bash", "-c", "awww img '" + wp + "'"]
        procApply.running = true
        root.visible = false
    }

    Process {
        id: procList
        command: ["bash"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseWallpapers(this.text)
            }
        }
    }

    Process {
        id: procApply
        command: ["bash"]
    }

    Rectangle {
        color: Colors.palette.base00
        anchors.fill: parent
        radius: 20
        clip: false

        Text {
            text: "Wallpapers"
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
            id: listView
            anchors {
                top: parent.top
                topMargin: 40
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 8
            }
            spacing: 10
            clip: true
            model: wallpapers

            delegate: Rectangle {
                width: listView.width - 16
                height: 180
                radius: 12
                color: Colors.palette.base02
                // anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: 10
                    clip: false

                    Image {
                        anchors.fill: parent
                        source: "file://" + root.thumbPath(modelData)
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: mouseArea.containsMouse ? "#33ffffff" : "transparent"
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    height: 20
                    radius: 12
                    color: Colors.palette.base05

                    Text {
                        text: modelData.replace(/^thumb-/, "").replace(/\.[^.]+$/, "")
                        color: Colors.palette.base01
                        font.family: root.font
                        font.pixelSize: 14
                        anchors.centerIn: parent
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.applyWallpaper(modelData)
                }

                Behavior on scale {
                    NumberAnimation { duration: 100 }
                }
                scale: mouseArea.containsMouse ? 1.06 : 1.0
            }
        }
    }
}
