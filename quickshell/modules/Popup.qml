import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    id: root

    PanelWindow {
        implicitWidth: 200
        implicitHeight: 40

        anchors {
            top: true
        }

        WlrLayershell.margins {
            top: 100     // distancia desde el borde superior
            left: 800   // distancia desde el borde izquierdo
        }

        color: "transparent"
        // WlrLayershell.exclusiveZone: -1

        Item {
            width: parent.width 
            height: parent.height

            Rectangle {
                id: nofificationBox
                anchors.fill: parent
                width: 200;
                height: 40;
                border.width: 1
                radius: 10
                color: "black"

                Text {
                    anchors.centerIn: parent  // centrado perfecto 🎯
                    text: "Hola mundo"
                    color: "white"
                    font.pixelSize: 18
                }
            }
        }
    }
}
