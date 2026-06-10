import Quickshell.Wayland
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
    property var icons: [ "", "", "" ]

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activespecial") {
                // event.data puede venir como "WORKSPACE_NAME" o "WORKSPACE_NAME,MONITOR"
                // Extraemos solo el nombre del workspace para comparar
                var data = event.data || ""
                var sepIdx = data.indexOf(",")
                root.activeSpecialName = sepIdx !== -1 ? data.substring(0, sepIdx) : data
            }
        }
    }

    Loader {
        anchors.fill: parent
        sourceComponent: verticalComp
    }

    Component {
        id: verticalComp

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 10

            Repeater {
                model: Hyprland.workspaces

                delegate: Rectangle {
                    id: workspaceDot

                    property bool isSpecial: modelData.id < 0
                    // Coincide si los nombres son iguales, o si modelData.name trae
                    // además el monitor como sufijo (e.g. "special:scratch,HDMI-A-1").
                    property bool nameMatches: isSpecial && root.activeSpecialName.length > 0 && (
                        root.activeSpecialName === modelData.name
                        || modelData.name.indexOf(root.activeSpecialName + ",") === 0
                    )
                    property bool isFocused: isSpecial ? nameMatches : modelData.focused
                    property bool isActive: isSpecial ? nameMatches : modelData.active
                    width: 28
                    height: 28
                    radius: width / 3

                    color: {
                        if (isFocused)
                            return Colors.palette.base0D
                            // return isSpecial ? 
                            //     Colors.palette.base0D : Colors.palette.base0D

                        if (mouseArea.containsMouse)
                            return Colors.palette.base03

                        return Colors.palette.base01
                    }
                    border.width: isActive ? 2 : 0
                    border.color: isFocused ? Colors.palette.base0D : Colors.palette.base00

                    Layout.alignment: Qt.AlignHCenter

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                        }
                    }

                    scale: mouseArea.containsMouse ? 1.15 : 1.0

                    Text {
                        anchors.centerIn: parent

                        text: (modelData.id < 4 && modelData.id > 0) ? icons[modelData.id - 1] : isSpecial ? "S" : modelData.id

                        color: isFocused ? Colors.palette.base00 : Colors.palette.base0F
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

                        onClicked: {
                            modelData.activate()
                        }
                    }
                }
            }
        }
    }
}
