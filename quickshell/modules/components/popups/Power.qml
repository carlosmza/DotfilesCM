import Quickshell
import QtQuick
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
        id: powerMenu
        width: parent.width
        height: 50
        color: "black"
        property bool hovered: false

        Text {
            anchors.centerIn: parent
            text: "HH" // Representación de tu reloj
            color: "white"
        }

        // --- DETECTOR DE HOVER ---
        MouseArea {
            anchors.fill: parent
            hoverEnabled: powerMenu.hovered = true
            onEntered: console.log("PowerMenu onEntered:", powerMenu.hovered)
            onExited: console.log("PowerMenu onExited:", powerMenu.hovered)
            // onEntered: (root.hovered = tue) && console.log("PowerMenu onEntered:", root.hovered)
            // onExited: (root.hovered = false) && console.log("PowerMenu onExited:", root.hovered)
            onClicked: {
                console.log("PowerMenu clicked")
                powerMenu.hovered = !powerMenu.hovered
            }
        }

        // --- EL POPUP ---
        PopupWindow {
            id: powerPopup
            
            // Se ancla a la derecha de la barra lateral
            anchor.window: bar
            anchor.rect.x: bar.width + 50 // 5px de separación
            anchor.rect.y: powerMenu.y
            
            // Se muestra solo cuando el ratón está encima del trigger
            // visible: powerHover.hovered
            // visible: false
            // enable: false
            
            width: 150
            height: 100

            Rectangle {
                anchors.fill: parent
                color: "#1e1e2e"
                radius: 8
                border.color: "#313244"

                Column {
                    anchors.centerIn: parent
                    Text { text: "Detalle de fecha"; color: "white"; font.bold: true }
                    Text { text: Qt.formatDateTime(new Date(), "dddd, MMMM"); color: "#a6adc8" }
                }
            }
        }
}