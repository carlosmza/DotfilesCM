import Quickshell
import Quickshell.Io
import QtQuick
import qs.config.theme
import qs.config.fonts

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    color: "transparent"
    exclusiveZone: -1
    focusable: true
    visible: false

    property int currentIndex: 0
    property bool open: false
    property var monitors: []
    readonly property bool hasExternalMonitor: monitors.some(function(monitor) {
        return monitor.name !== "eDP-1"
    })
    readonly property bool isMirrored: monitors.some(function(monitor) {
        return monitor.mirrorOf && monitor.mirrorOf !== "none"
    })
    readonly property string activeMode: root.isMirrored
        ? "mirror"
        : (root.monitors.length > 1 ? "extend" : "none")
    readonly property var modes: [
        { key: "extend", label: qsTr("Extend"), icon: "󰍺" },
        { key: "mirror", label: qsTr("Mirror"), icon: "" }
    ]

    function showMenu() {
        root.currentIndex = 0
        root.visible = true
        root.open = true
        refreshMonitors()
        menuContent.forceActiveFocus()
    }

    function hideMenu() {
        root.open = false
        closeTimer.restart()
    }

    function toggleMenu() {
        if (root.visible && root.open)
            root.hideMenu()
        else
            root.showMenu()
    }

    function refreshMonitors() {
        monitorProcess.running = true
    }

    function parseMonitors(output) {
        try {
            root.monitors = JSON.parse(output)
        } catch (error) {
            root.monitors = []
        }
    }

    function applyMode() {
        if (!root.hasExternalMonitor)
            return

        var command = root.modes[root.currentIndex].key === "mirror"
            ? "hyprctl eval \"hl.monitor({ output = 'eDP-1', mode = '1920x1080@60', position = '0x0', scale = '1' })\"; "
                + "hyprctl eval \"hl.monitor({ output = 'HDMI-A-1', mode = '0', position = '0x0', mirror = 'eDP-1' })\""
            : "hyprctl eval \"hl.monitor({ output = 'eDP-1', mode = '1920x1080@60', position = '0x0', scale = '1', mirror = '' })\"; "
                + "hyprctl eval \"hl.monitor({ output = 'HDMI-A-1', mode = '1920x1080@100', position = '1920x0', scale = '1', mirror = '' })\"; "
                + "hyprctl dispatch moveworkspacetomonitor '1 eDP-1'; "
                + "hyprctl dispatch moveworkspacetomonitor '2 HDMI-A-1'"

        modeProcess.command = ["bash", "-c", command]
        root.hideMenu()
        modeProcess.running = true
    }

    function moveSelection(delta) {
        root.currentIndex = (root.currentIndex + delta + root.modes.length) % root.modes.length
    }

    Timer {
        id: closeTimer
        interval: 180
        onTriggered: {
            if (!root.open)
                root.visible = false
        }
    }

    Process {
        id: monitorProcess
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.parseMonitors(this.text)
        }
    }

    Process {
        id: modeProcess
        command: ["true"]
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Colors.palette.base00, 0.62)
        opacity: root.open ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

        MouseArea {
            anchors.fill: parent
            onClicked: root.hideMenu()
        }
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: 420
        height: 250
        color: Colors.palette.base00
        border.color: Colors.palette.base02
        border.width: 2
        radius: 15
        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.96
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked: mouse.accepted = true
        }

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            Text {
                width: parent.width
                height: 22
                text: qsTr("Monitors")
                color: Colors.palette.base05
                font.pixelSize: 15
                font.bold: true
                font.family: Fonts.varelaRound
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                width: parent.width
                height: 28
                text: root.monitors.length
                    ? root.monitors.map(function(monitor) {
                        return monitor.name + " " + monitor.width + "x" + monitor.height
                            + "@" + Math.round(monitor.refreshRate) + "Hz"
                    }).join("  ·  ")
                    : qsTr("Unable to detect monitors")
                color: root.hasExternalMonitor ? Colors.palette.base04 : Colors.palette.base08
                font.pixelSize: 11
                font.family: Fonts.varelaRound
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                height: 18
                text: root.hasExternalMonitor
                    ? qsTr("Active mode: %1").arg(root.activeMode === "mirror" ? qsTr("Mirror") : qsTr("Extend"))
                    : qsTr("No external monitor detected")
                color: root.hasExternalMonitor ? Colors.palette.base03 : Colors.palette.base08
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
            }

            Row {
                id: menuContent
                width: parent.width
                height: 112
                spacing: 10
                focus: true

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Left) {
                        root.moveSelection(-1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Right) {
                        root.moveSelection(1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.applyMode()
                        event.accepted = true
                    } else if (event.key === Qt.Key_Escape) {
                        root.hideMenu()
                        event.accepted = true
                    } else if (event.key === Qt.Key_F5) {
                        root.refreshMonitors()
                        event.accepted = true
                    }
                }

                Repeater {
                    model: root.modes

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: 185
                        height: 112
                        radius: 12
                        opacity: root.hasExternalMonitor ? 1 : 0.45
                        color: index === root.currentIndex && modelData.key === root.activeMode
                            ? Colors.palette.base02
                            : (index === root.currentIndex
                                ? Colors.palette.base01 : "transparent")
                        border.color: index === root.currentIndex
                            ? Colors.palette.base03 : "transparent"
                        border.width: index === root.currentIndex ? 1 : 0
                        scale: index === root.currentIndex ? 1.04 : 1
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on opacity { NumberAnimation { duration: 120 } }
                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                        Text {
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                top: parent.top
                                topMargin: 18
                            }
                            text: modelData.icon
                            color: Colors.palette.base05
                            font.pixelSize: 34
                            font.family: Fonts.varelaRound
                        }

                        Text {
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                bottom: parent.bottom
                                bottomMargin: 16
                            }
                            text: modelData.label
                            color: Colors.palette.base05
                            font.pixelSize: 13
                            font.bold: index === root.currentIndex
                            font.family: Fonts.varelaRound
                        }

                        MouseArea {
                            id: buttonMouse
                            anchors.fill: parent
                            enabled: root.hasExternalMonitor
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.currentIndex = index
                            onClicked: {
                                root.currentIndex = index
                                root.applyMode()
                            }
                        }
                    }
                }
            }

            Text {
                width: parent.width
                height: 18
                text: qsTr("← → navigate · Enter apply · Esc close")
                color: Colors.palette.base03
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
