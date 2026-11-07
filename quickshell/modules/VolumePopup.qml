import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.config.theme

ShellRoot {
    id: root

    Volume {
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
            border.color: "#30" + Colors.palette.base04.slice(1) // Implementacion de alpha #AARRGGBB
            radius: 6
            opacity: mostrar ? 1.0 : 0.0
            visible: opacity > 0.0
            enabled: opacity > 0.0

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            Behavior on anchors.topMargin {
                NumberAnimation { duration: 150 }
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
                anchors.rightMargin: Math.min(osdPanel.implicitWidth - svc.volumeValue * 3, 305)
                anchors.leftMargin: 5
                anchors.topMargin: 5
                anchors.bottomMargin: 5
                color: Colors.palette.base02
                radius: 6

                Behavior on anchors.rightMargin {
                    SmoothedAnimation { duration: 150; easing: Easing.OutCubic }
                }

                Text {
                    text: "󰽴"
                    color: svc.volumeValue < svc.threshold ? Colors.palette.base05 : Colors.palette.base06
                    font.pixelSize: 18
                    x: svc.volumeValue < svc.threshold ? osdPanel.implicitWidth - 50 : osdPanel.implicitWidth - 120
                    y: 5
                }
            }


            Rectangle {
                id: levelItem
                width: 5
                height: parent.height - 10
                color: Colors.palette.base05
                radius: 6
                x: Math.max(svc.volumeValue * 3 - 2, 5)
                y: 5

                Behavior on x {
                    SmoothedAnimation { duration: 150; easing: Easing.OutCubic }
                }
            }
        }
    }
}
