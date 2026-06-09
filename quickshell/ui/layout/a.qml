import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import qs.config.theme
import qs.config.fonts

Item {
    id: root

    implicitWidth: 45
    implicitHeight: 50

    property string font: Fonts.varelaRound
    property bool specialFocused: false
    property var icons: [ "", "", "" ]

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activespecial") {
                root.specialFocused = !root.specialFocused
                console.log("data:", event.data)
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
                    property bool isFocused: isSpecial ? root.specialFocused : modelData.focused
                    property bool isActive: {
                        if (isSpecial)
                            return root.specialFocused
                        return modelData.active
                    }
                    width: 28
                    height: 28
                    radius: width / 3

                    color: {
                        if (isFocused)
                            return isSpecial ? 
                                Colors.palette.base0D : Colors.palette.base0D

                        if (mouseArea.containsMouse)
                            return Colors.palette.base03

                        return Colors.palette.base01
                    }
                    border.width: isActive ? 2 : 0
                    border.color: modelData.focused  ?  Colors.palette.base0D : Colors.palette.base00

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

                        text: {
                            if (modelData.id === -97) return ""
                            if (modelData.id === -98) return ""
                            if (modelData.id < 4 && modelData.id > 0) return root.icons[modelData.id -1]
                            // return isSpecial ? "" : modelData.id
                            return modelData.id
                        }

                        // visible: isSpecial || modelData.id === 2 || modelData.id === 3 || modelData.id > 3
                        visible: true

                        color: {
                            if (modelData.focused)
                                return Colors.palette.base00
                            if (root.specialFocused)
                                return Colors.palette.base00
                            return Colors.palette.base0F
                        }
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
