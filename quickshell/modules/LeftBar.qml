import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "components"

PanelWindow {
    id: root
    // Configuración de anclaje para barra lateral izquierda
    anchors {
        top: true
        left: true
        bottom: true
    }
    implicitWidth: 40
    color: "#000000" // Un tono oscuro tipo Tokyo Night

    // Layout principal: Organiza los bloques verticalmente
    Item {
        anchors.fill: parent
        anchors.margins: 28

        Workspaces {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Window {
            anchors.centerIn: parent
        }

        Clock {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Wifi {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 28
        }

        Battery {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 28
        }

        // Helloworld {
        // }
        // PowerMenu {
        //     anchors.horizontalCenter: parent.horizontalCenter
        //     anchors.bottom: parent.bottom
        // }
    }
}
