import Quickshell
import Quickshell.Io
import QtQuick 2.15
import QtQuick.Layouts
import "../components"
import qs.config.theme

PanelWindow {
    id: root
    // Configuración de anclaje para barra lateral izquierda
    anchors {
        top: true
        left: true
        bottom: true
    }
    implicitWidth: 40
    color: Colors.palette.base00

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
