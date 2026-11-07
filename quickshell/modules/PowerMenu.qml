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
    property bool armed: false
    property bool open: false
    readonly property var actions: [
        { key: "suspend", label: qsTr("Suspend"), icon: "", command: ["systemctl", "suspend"], confirm: false },
        { key: "poweroff", label: qsTr("Poweroff"), icon: "", command: ["systemctl", "poweroff"], confirm: true },
        { key: "reboot", label: qsTr("Reboot"), icon: "", command: ["systemctl", "reboot"], confirm: true },
        { key: "lock", label: qsTr("Lock"), icon: "", command: ["hyprlock"], confirm: false }
    ]

    function showMenu() {
        root.currentIndex = 0
        root.armed = false
        root.visible = true
        root.open = true
        menuContent.forceActiveFocus()
    }

    function hideMenu() {
        root.armed = false
        root.open = false
        closeTimer.restart()
    }

    function toggleMenu() {
        if (root.visible && root.open)
            root.hideMenu()
        else
            root.showMenu()
    }

    function moveSelection(delta) {
        root.currentIndex = (root.currentIndex + delta + root.actions.length) % root.actions.length
        root.armed = false
    }

    function selectCurrent() {
        var action = root.actions[root.currentIndex]
        if (action.confirm && !root.armed) {
            root.armed = true
            return
        }

        actionProcess.command = action.command
        root.hideMenu()
        actionProcess.running = true
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
        id: actionProcess
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
        width: 560
        height: 210
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
                text: root.armed ? qsTr("Press Enter again to confirm") : qsTr("System")
                color: root.armed ? Colors.palette.base08 : Colors.palette.base05
                font.pixelSize: 15
                font.bold: true
                font.family: Fonts.varelaRound
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Row {
                id: menuContent
                width: parent.width
                height: 112
                spacing: 8
                focus: true

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Left) {
                        root.moveSelection(-1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Right) {
                        root.moveSelection(1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.selectCurrent()
                        event.accepted = true
                    } else if (event.key === Qt.Key_Escape) {
                        if (root.armed)
                            root.armed = false
                        else
                            root.hideMenu()
                        event.accepted = true
                    }
                }

                Repeater {
                    model: root.actions

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: 124
                        height: 112
                        radius: 12
                        color: index === root.currentIndex
                            ? (index === 1 || index === 2) && root.armed
                                ? Qt.alpha(Colors.palette.base08, 0.25)
                                : Colors.palette.base02
                            : (buttonMouse.containsMouse ? Colors.palette.base01 : "transparent")
                        border.color: index === root.currentIndex
                            ? ((index === 1 || index === 2) && root.armed ? Colors.palette.base08 : Colors.palette.base03)
                            : "transparent"
                        border.width: index === root.currentIndex ? 1 : 0
                        scale: index === root.currentIndex ? 1.04 : 1
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on border.color { ColorAnimation { duration: 120 } }
                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                        Text {
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                top: parent.top
                                topMargin: 18
                            }
                            text: modelData.icon
                            color: index === root.currentIndex && root.armed
                                ? Colors.palette.base08 : Colors.palette.base05
                            font.pixelSize: 34
                            font.family: Fonts.varelaRound
                        }

                        Text {
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                bottom: parent.bottom
                                bottomMargin: 16
                            }
                            text: index === root.currentIndex && root.armed
                                ? qsTr("Confirm?") : modelData.label
                            color: index === root.currentIndex && root.armed
                                ? Colors.palette.base08 : Colors.palette.base05
                            font.pixelSize: 13
                            font.bold: index === root.currentIndex
                            font.family: Fonts.varelaRound
                        }

                        MouseArea {
                            id: buttonMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: {
                                root.currentIndex = index
                                root.armed = false
                            }
                            onClicked: {
                                root.currentIndex = index
                                root.selectCurrent()
                            }
                        }
                    }
                }
            }

            Text {
                width: parent.width
                height: 18
                text: root.armed
                    ? qsTr("Enter confirm · Esc cancel")
                    : qsTr("← → navigate · Enter select · Esc close")
                color: Colors.palette.base03
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
