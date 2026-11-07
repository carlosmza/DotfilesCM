pragma ComponentBehavior: Bound

import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import qs.config.theme
import qs.config.fonts

Item {
    id: root

    implicitWidth: 50
    implicitHeight: 50

    property string font: Fonts.varelaRound
    property string activeSpecialName: ""
    property var windowIconMap: { "ytm": "", "notes": "" }

    function iconForName(name) {
        if (!name)
            return ""
        for (var key in root.windowIconMap)
            if (name === key)
                return root.windowIconMap[key]
        return ""
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activespecial") {
                // event.data puede venir como "WORKSPACE_NAME" o "WORKSPACE_NAME,MONITOR"
                var data = event.data || ""
                var sepIdx = data.indexOf(",")
                root.activeSpecialName = sepIdx !== -1 ? data.substring(0, sepIdx) : data
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 10

        Repeater {
            model: Hyprland.workspaces

            delegate: Rectangle {
                id: workspaceDot

                required property var modelData

                readonly property bool isSpecial: modelData.id < 0
                // Coincide si los nombres son iguales, o si modelData.name trae
                // además el monitor como sufijo (e.g. "special:scratch,HDMI-A-1").
                readonly property bool nameMatches: isSpecial && root.activeSpecialName.length > 0 && (
                    root.activeSpecialName === modelData.name
                    || modelData.name.indexOf(root.activeSpecialName + ",") === 0
                )
                readonly property bool isFocused: isSpecial ? nameMatches : modelData.focused
                readonly property bool isActive: isSpecial ? nameMatches : modelData.active
                readonly property string windowIcon: {
                    var toplevels = modelData.toplevels.values || []
                    for (var i = 0; i < toplevels.length; i++) {
                        var tl = toplevels[i]
                        var icon = root.iconForName(tl.wayland && tl.wayland.appId ? tl.wayland.appId : "")
                            || root.iconForName(tl.title)
                        if (icon)
                            return icon
                    }
                    return ""
                }

                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                Layout.alignment: Qt.AlignHCenter
                radius: width / 3

                color: {
                    if (isFocused)
                        return Colors.palette.base0D

                    if (mouseArea.containsMouse)
                        return Colors.palette.base03

                    return Colors.palette.base01
                }
                border.width: isActive ? 2 : 0
                border.color: isFocused ? Colors.palette.base0D : Colors.palette.base00

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on scale { NumberAnimation { duration: 120 } }

                scale: mouseArea.containsMouse ? 1.15 : 1.0

                Text {
                    anchors.centerIn: parent
                    text: workspaceDot.windowIcon ? workspaceDot.windowIcon : workspaceDot.isSpecial ? "" : workspaceDot.modelData.id
                    color: workspaceDot.isFocused ? Colors.palette.base00 : Colors.palette.base0F
                    font {
                        pixelSize: 16
                        bold: true
                        family: root.font
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: workspaceDot.modelData.activate()
                }
            }
        }
    }
}
