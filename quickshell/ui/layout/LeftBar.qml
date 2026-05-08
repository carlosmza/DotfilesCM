import Quickshell
import Quickshell.Io
import QtQuick 2.15
import QtQuick.Layouts
import "../components"
import qs.config.theme

PanelWindow {
    id: root
    anchors {
        top: true
        left: true
        bottom: true
    }

    margins {
        left: 5
        top: 5
        bottom: 5
        right: 5
    }
    implicitWidth: 35
    color: "transparent"

    Rectangle {
        color: Colors.palette.base00
        anchors.fill: parent
        radius: 15
        clip: true

        Workspaces {
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
        }

        Window {
            anchors {
                centerIn: parent
            }
        }

        Clock {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
        }

        Wifi {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                margins: 28
            }
        }

        Battery {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                margins: 28
            }
        }

        // Helloworld {
        // }
        // PowerMenu {
        //     anchors.horizontalCenter: parent.horizontalCenter
        //     anchors.bottom: parent.bottom
        // }
    }
}
