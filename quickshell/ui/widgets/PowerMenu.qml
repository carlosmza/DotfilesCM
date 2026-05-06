import QtQuick 2.15
import QtQuick.Controls 2.15
import Quickshell
import Quickshell.Io
import "popups"

Item {
    id: root
    implicitWidth: 40
    implicitHeight: 40


    Text {
        id: icon
        text: "⏻"
        color: "white"
        font.pixelSize: 24
        anchors.centerIn: parent
    }

    Power {
        
    }
}