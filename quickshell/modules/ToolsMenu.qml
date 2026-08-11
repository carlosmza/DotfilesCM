import Quickshell
import Quickshell.Io
import QtQuick
import "../components"
import qs.config.theme

MenuLayout {
    id: root
    title: ""

    property bool hypridleActive: true

    property var toolsItems: [
        { icon: "", label: "Area", mode: "region" },
        { icon: "", label: "Fullscreen", mode: "output" },
        { icon: "", label: "Theme Selector", fn: "toggleThemeSelector" },
        { icon: "", label: "Wallpaper Selector", fn: "toggleWallpaperSelector" },
        { icon: hypridleActive ? "󱩎" : "󰹐", label: hypridleActive ? "Caffeine: ON" : "Caffeine: OFF", fn: "toggleHypridle" }
    ]

    Process { id: shotProc }
    Process { id: toggleTheme }
    Process { id: toggleWp }
    Process {
        id: hypridleCheck
        command: ["systemctl", "--user", "is-active", "hypridle"]
        running: true
        onStdoutChanged: if (stdout.trim() === "inactive") root.hypridleActive = false;
    }
    Process { id: hypridleProc }

    function takeShot(mode) {
        const now = new Date();
        const pad = (n) => n.toString().padStart(2, '0');
        const ts = `${now.getFullYear()}-${pad(now.getMonth()+1)}-${pad(now.getDate())}_${pad(now.getHours())}-${pad(now.getMinutes())}-${pad(now.getSeconds())}`;
        const filename = `Screenshot-From-${ts}.png`;

        shotProc.command = ["hyprshot", "-m", mode, "-o", "/home/carlosm/Pictures/Screenshots", "-f", filename];
        shotProc.running = true;
        root.closeRequested();
    }
    function toggleThemeSelector() {
        toggleTheme.command = ["quickshell", "ipc", "call", "theme", "toggle"]
        toggleTheme.running = true
        root.closeRequested()
    }

    function toggleWallpaperSelector() {
        toggleWp.command = ["quickshell", "ipc", "call", "wallpapers", "toggle"]
        toggleWp.running = true
        root.closeRequested()
    }

    function toggleHypridle() {
        hypridleProc.command = ["systemctl", "--user", hypridleActive ? "stop" : "start", "hypridle"];
        hypridleProc.running = true;
        hypridleActive = !hypridleActive;
        root.closeRequested();
    }

    Repeater {
        model: root.toolsItems

        delegate: Rectangle {
            border.color: Colors.palette.base01
            border.width: 1
            width: parent.width
            color: ma.containsMouse ? Colors.palette.base02 : "transparent"
            height: 32
            radius: 8

            Behavior on color { ColorAnimation { duration: 150 } }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: modelData.icon
                    color: Colors.palette.base05
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: modelData.label
                    color: Colors.palette.base05
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (modelData.fn) root[modelData.fn]();
                    else root.takeShot(modelData.mode);
                }
            }
        }
    }
}
