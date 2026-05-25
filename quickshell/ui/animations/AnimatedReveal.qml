import QtQuick
import Quickshell

Item {
    id: root
    property bool open: false
    default property alias contentData: contentArea.data

    Rectangle {
        id: container
        anchors.fill: parent
        color: "transparent"
        opacity: 0

        // Desplazamiento inicial a la izquierda
        x: -60

        Item {
            id: contentArea
            anchors.fill: parent
        }
    }

    states: [
        State {
            name: "visible"
            when: root.open
            PropertyChanges {
                target: container
                opacity: 1
                x: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: ""
            to: "visible"
            reversible: true

            ParallelAnimation {
                NumberAnimation {
                    target: container
                    property: "x"
                    to: 0
                    duration: 400
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: container
                    property: "opacity"
                    to: 1
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }
        }
    ]
}
