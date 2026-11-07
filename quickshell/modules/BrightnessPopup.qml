import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.config.theme

ShellRoot {
    id: root

    function mostrar() {
        osdItem.mostrar = true
        hideTimer.restart()
    }

    Brightness {
        id: svc
        onValueChanged: {
            osdItem.mostrar = true
            hideTimer.restart()
        }
    }

    PanelWindow {
        id: osdPanel
        anchors { top: true }
        implicitWidth: 310
        implicitHeight: 40
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.margins { top: Math.round(Screen.height * 0.12) }
        color: "transparent"

        Rectangle {
            id: osdItem
            property bool mostrar: false
            anchors.fill: parent
            anchors.topMargin: mostrar ? 0 : -30
            color: Colors.palette.base00
            border.color: "#10" + Colors.palette.base04.slice(1) // Implementacion de alpha #AARRGGBB
            radius: 6
            opacity: mostrar ? 1.0 : 0.0
            visible: opacity > 0.0
            enabled: opacity > 0.0

            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }

            Behavior on anchors.topMargin {
                NumberAnimation { duration: 200; easing: Easing.OutCubic }
            }

            Timer {
                id: hideTimer
                interval: 1000
                repeat: false
                onTriggered: osdItem.mostrar = false
            }

            Rectangle {
                id: fgItem
                anchors.fill: parent
                anchors.rightMargin: Math.min(osdPanel.implicitWidth - svc.brightnessValue * 3, 305)
                anchors.leftMargin: 5
                anchors.topMargin: 5
                anchors.bottomMargin: 5
                color: svc.backlightAvailable ? Colors.palette.base02 : Colors.palette.base01
                radius: 6

                Behavior on anchors.rightMargin {
                    SmoothedAnimation { duration: 150; easing: Easing.OutCubic  }
                }

                Text {
                    text: "󰃟"
                    color: svc.brightnessValue < svc.threshold ? Colors.palette.base05 : Colors.palette.base06
                    font.pixelSize: 18
                    x: svc.brightnessValue < svc.threshold ? osdPanel.implicitWidth - 50 : osdPanel.implicitWidth - 65
                    y: 5
                }
            }

            Rectangle {
                id: levelItem
                width: 5
                height: parent.height - 10
                color: Colors.palette.base05
                radius: 6
                x: Math.max(svc.brightnessValue * 3 - 2, 5)
                y: 5

                Behavior on x {
                    SmoothedAnimation { duration: 150; easing: Easing.OutCubic}
                }
            }
        }
    }
}
