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

    implicitHeight: 280
    implicitWidth: Math.min(Math.max(wallpapers.length * 340, 400), 1400)
    color: "transparent"
    exclusiveZone: -1
    visible: false
    focusable: true

    onVisibleChanged: {
        if (visible) {
            root.applying = false
            if (wallpapers.length === 0) loadWallpapers()
            wpContent.forceActiveFocus()
        }
    }

    property var wallpapers: []
    property int selectedIndex: -1
    property string font: Fonts.varelaRound
    property int fontSize: 14
    property bool applying: false
    property int previousIndex: -1

    Component.onCompleted: loadWallpapers()

    onSelectedIndexChanged: {
        if (previousIndex < 0) {
            previousIndex = selectedIndex
            listView.currentIndex = selectedIndex
            return
        }
        listView.currentIndex = selectedIndex
        scrollToSelected()
        previousIndex = selectedIndex
    }

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
        var name = thumbName.replace(/^thumb-/, "")
        return "/home/carlosm/Pictures/Wallpapers/" + name
    }

    function thumbPath(thumbName) {
        return "/home/carlosm/Pictures/wallpaper_thumbs/" + thumbName
    }

    function applyWallpaper(thumbName) {
        if (root.applying) return
        root.applying = true
        var wp = wallpaperFromThumb(thumbName)
        procApply.command = ["/home/carlosm/.config/scripts/system/wallpaper-change.py", wp]
        procApply.running = true
    }

    function scrollToSelected() {
        if (wallpapers.length === 0) return
        var itemWidth = 320 + 15
        var viewWidth = listView.width
        if (viewWidth <= 0) return
        var itemsPerView = Math.max(1, Math.floor(viewWidth / itemWidth))
        var firstVisible = Math.floor(listView.contentX / itemWidth)
        var lastVisible = firstVisible + itemsPerView - 1

        if (selectedIndex >= firstVisible && selectedIndex <= lastVisible)
            return

        var movingRight = selectedIndex > previousIndex
        var targetX
        if (movingRight)
            targetX = selectedIndex * itemWidth
        else
            targetX = Math.max(0, (selectedIndex - itemsPerView + 1) * itemWidth)

        scrollAnim.from = listView.contentX
        scrollAnim.to = targetX
        scrollAnim.start()
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
        onRunningChanged: {
            if (!running && root.applying) {
                root.applying = false
                root.visible = false
            }
        }
    }

    Rectangle {
        id: wpContent
        // color: Colors.palette.base00
        color: "transparent"
        anchors.fill: parent
        radius: 20
        clip: false
        focus: true
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                if (root.applying) return
                root.visible = false
                event.accepted = true
            } else if (event.key === Qt.Key_Left) {
                if (selectedIndex > 0)
                    selectedIndex--
                else
                    selectedIndex = wallpapers.length - 1
                event.accepted = true
            } else if (event.key === Qt.Key_Right) {
                if (selectedIndex < wallpapers.length - 1)
                    selectedIndex++
                else
                    selectedIndex = 0
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (!root.applying && selectedIndex >= 0 && selectedIndex < wallpapers.length) {
                    root.applyWallpaper(wallpapers[selectedIndex])
                }
                event.accepted = true
            } else if (event.key === Qt.Key_F5) {
                loadWallpapers()
                event.accepted = true
            }
        }

        ListView {
            id: listView
            anchors {
                top: parent.top
                topMargin: 48
                left: parent.left
                leftMargin: 8
                right: parent.right
                rightMargin: 8
                bottom: parent.bottom
                bottomMargin: 8
            }
            orientation: ListView.Horizontal
            spacing: 15
            clip: false
            model: wallpapers
            currentIndex: selectedIndex
            interactive: !root.applying

            NumberAnimation {
                id: scrollAnim
                target: listView
                property: "contentX"
                duration: 250
                easing.type: Easing.OutCubic
            }

            delegate: Item {
                width: 320
                height: listView.height
                enabled: !root.applying
                opacity: enabled ? 1.0 : 0.5

                Rectangle {
                    id: card
                    width: parent.width
                    height: parent.height
                    radius: 10

                    y: (mouseArea.containsMouse || index === selectedIndex) ? -40 : 0
                    Behavior on y { NumberAnimation { duration: 140 } }

                    Image {
                        anchors.fill: parent
                        source: "file://" + root.thumbPath(modelData)
                        fillMode: Image.PreserveAspectCrop

                    }

                    Rectangle {
                        anchors.fill: parent
                        color: {
                            if (mouseArea.containsMouse)
                                return "#15ffffff"
                            if (index === selectedIndex)
                                return "#30ffffff"
                            return "transparent"
                        }
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
                        root.applyWallpaper(modelData)
                    }
                }

                Behavior on scale {
                    NumberAnimation { duration: 140 }
                }
                scale: (mouseArea.containsMouse || index === selectedIndex) ? 1.04 : 1.0
            }
        }

        Text {
            anchors.centerIn: parent
            text: "No wallpapers found\nPress F5 to reload"
            color: Colors.palette.base03
            horizontalAlignment: Text.AlignHCenter
            visible: wallpapers.length === 0 && !root.applying
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
