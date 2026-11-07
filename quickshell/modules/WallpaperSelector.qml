import Quickshell
import Quickshell.Io
import QtQuick
import Qt5Compat.GraphicalEffects
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
        bottom: 0
    }

    implicitHeight: 400
    color: "transparent"
    exclusiveZone: -1
    visible: false
    focusable: true

    property var wallpapers: []
    property int currentIndex: 0
    property int previousIndex: -1
    property string font: Fonts.varelaRound
    property int fontSize: 14
    property bool applying: false
    property bool _stayOpen: false
    property int _hoveredIndex: -1
    property bool _timerFromHover: false
    property bool _settingFromTimer: false

    property real cx: root.width / 2
    property real cy: root.height - 90
    property real rx: 380
    property real ry: 120
    property real cardWidth: 280
    property real cardHeight: 180

    onVisibleChanged: {
        if (visible) {
            root.applying = false
            root._hoveredIndex = -1
            root._timerFromHover = false
            if (wallpapers.length === 0) loadWallpapers()
            wpContent.forceActiveFocus()
        } else {
            applyTimer.stop()
        }
    }

    Component.onCompleted: loadWallpapers()

    onCurrentIndexChanged: {
        if (previousIndex < 0) {
            previousIndex = currentIndex
            return
        }
        previousIndex = currentIndex
        if (!root._settingFromTimer && visible) {
            root._timerFromHover = false
            applyTimer.restart()
        }
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

    function applyWallpaper(thumbName, stayOpen) {
        if (root.applying) return
        root.applying = true
        root._stayOpen = stayOpen || false
        var wp = wallpaperFromThumb(thumbName)
        procApply.command = ["awww", "img", wp, "--transition-type", "wipe", "--transition-duration", "2", "--transition-fps", "60"]
        procApply.running = true
    }

    function angleFor(index) {
        if (wallpapers.length < 2) return 90
        return 180 - index * 180 / (wallpapers.length - 1)
    }

    function orbitPosition(angleDeg) {
        const angleRad = angleDeg * Math.PI / 180
        return {
            // x: root.cx + root.rx * Math.cos(angleRad),
            x: angleDeg === 180 ? root.cx - 20 + root.rx * Math.cos(angleRad) : 
                angleDeg === 0 ? root.cx + 20 + root.rx * Math.cos(angleRad) : 
                root.cx + root.rx * Math.cos(angleRad),
            y: root.cy - root.ry * Math.sin(angleRad)
        }
    }

    function gaussianValue (x) {
        const mu = 90.0
        const sigma = 3
        const aplitude = 10.0

        return aplitude * Math.exp(-Math.pow(x - mu, 2) / (2 * Math.pow(sigma, 2)))
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
                if (!root._stayOpen)
                    root.visible = false
                root._stayOpen = false
            }
        }
    }

    Timer {
        id: applyTimer
        interval: 500 /////
        onTriggered: {
            if (root.applying) return
            var idx = root._timerFromHover ? root._hoveredIndex : root.currentIndex
            if (idx >= 0 && idx < root.wallpapers.length) {
                root._settingFromTimer = true
                root.currentIndex = idx
                root._settingFromTimer = false
                root.applyWallpaper(root.wallpapers[idx], true)
            }
        }
    }

    Rectangle {
        id: wpContent
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
            } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
                if (root.wallpapers.length > 0) {
                    root.currentIndex = (root.currentIndex - 1 + root.wallpapers.length) % root.wallpapers.length
                }
                event.accepted = true
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
                if (root.wallpapers.length > 0) {
                    root.currentIndex = (root.currentIndex + 1) % root.wallpapers.length
                }
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (!root.applying && root.wallpapers.length > 0) {
                    root.applyWallpaper(root.wallpapers[root.currentIndex])
                }
                event.accepted = true
            } else if (event.key === Qt.Key_F5) {
                loadWallpapers()
                event.accepted = true
            }
        }

        Repeater {
            id: orbiter
            model: wallpapers
            delegate: Item {
                id: card
                width: root.cardWidth
                height: root.cardHeight

                property real itemAngle: root.angleFor(index)
                property var itemPos: root.orbitPosition(itemAngle)
                property bool isFocused: index === root.currentIndex
                property bool isHovered: mouseArea.containsMouse

                x: itemPos.x - width / 2
                // Evita salirse de la patalla hacia abajo y genera una mejor curva superior
                y: (itemAngle === 180 || itemAngle === 0) && isFocused ?
                    itemPos.y - height / 2 - 10 : 
                    (itemAngle > 80 && itemAngle < 100) ?
                    itemPos.y - height / 2 - gaussianValue(itemAngle) : 
                    itemPos.y - height / 2
                z: isFocused ? 5000 : (180 - itemAngle) / 180 * 2000
                scale: isFocused || isHovered ? 1.1 : 1.0

                Behavior on x { SmoothedAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on y { SmoothedAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                Rectangle {
                    id: bg
                    anchors.fill: parent
                    // radius: 12
                    color: isFocused ? Colors.palette.base02 : "transparent"
                    layer.enabled: true
                    layer.effect: DropShadow {
                        verticalOffset: isFocused ? 12 : 6
                        radius: isFocused ? 20 : 10
                        color: Qt.rgba(0, 0, 0, isFocused ? 0.5 : 0.3)
                        samples: 16
                    }
                }

                Image {
                    anchors.fill: bg
                    anchors.margins: 3
                    source: "file://" + root.thumbPath(modelData)
                    fillMode: Image.PreserveAspectCrop
                    clip: true
                }

                Rectangle {
                    id: dim
                    anchors.fill: bg
                    anchors.margins: 3
                    color: "black"
                    opacity: (isFocused || isHovered) ? 0.0 : 0.4
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        root._hoveredIndex = index
                        root._timerFromHover = true
                        applyTimer.restart()
                    }
                    onExited: {
                        if (root._hoveredIndex === index) {
                            root._hoveredIndex = -1
                            root._timerFromHover = false
                            applyTimer.stop()
                        }
                    }
                    onClicked: {
                        if (root.applying) return
                        applyTimer.stop()
                        root.currentIndex = index
                        root.applyWallpaper(modelData)
                    }
                }
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
    }
}
