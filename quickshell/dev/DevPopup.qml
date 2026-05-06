import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick 2.15
import qs.config.theme

ShellRoot {
    id: root
    PanelWindow {
        id: osdPanel
        anchors { top: true }
        implicitWidth: 200
        implicitHeight: 40
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.margins { top: 80; left: 800 }
        color: "transparent"

        Rectangle {
            id: osdItem
            property bool mostrar: true
            anchors.fill: parent
            color: Colors.term9
            // color: "black"
            radius: 6
            opacity: mostrar ? 1.0 : 0.0
            visible: opacity > 0
            enabled: opacity > 0

            // 🔥 Animación suave
            Behavior on opacity {
                NumberAnimation { duration: 400 }
            }


            Timer {
                id: hideTimer
                interval: 3000
                repeat: true
                running: true
                onTriggered: osdItem.mostrar = !osdItem.mostrar
            }

            Text {
                anchors.centerIn: parent
                // text: "Hola mundo"
                // text: Colors.name + Colors.primaryPaletteKeyColor
                // primary_paletteKeyColor": "417da2", "secondary_paletteKeyColor": "657a8a"}}


                // text: Colors.surface


                // color: Colors.onBackground
                color: "black"
                font.pixelSize: 18
            }
        }
    }
}
