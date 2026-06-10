import Quickshell
import Quickshell.Io
import QtQuick
import qs.config.theme
import qs.config.fonts

PanelWindow {
    id: root
    anchors {
        bottom: true
        left: true
        right: true
    }

    margins {
        left: 40
        bottom: 10
        right: 40
    }

    implicitHeight: 240
    color: "transparent"
    exclusiveZone: -1
    visible: false


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
        id: wpContent
        // color: Colors.palette.base00
        color: "transparent"
        anchors.fill: parent
        radius: 0
        clip: false
        focus: true
        Keys.onEscapePressed: root.visible = false

        ListView {
            id: listView
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: 6
                bottomMargin: 6
                leftMargin: 8
                rightMargin: 8
            }
            orientation: ListView.Horizontal
            spacing: 15
            clip: false
            model: wallpapers

            delegate: Item {
                width: 320
                height: listView.height

                // Card
                Rectangle {
                    id: card
                    width: parent.width
                    height: parent.height
                    color: "transparent"

                    y: mouseArea.containsMouse ? -20 : 0
                    Behavior on y { NumberAnimation { duration: 140 } }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 0
                        radius: 0
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
                        // (ARGB)
                        color: mouseArea.containsMouse ? "#10ffffff" : "transparent"
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
                    NumberAnimation { duration: 140 }
                }
                scale: mouseArea.containsMouse ? 1.04 : 1.0
            }
        }
    }
}
