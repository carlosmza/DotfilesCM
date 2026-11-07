import Quickshell.Hyprland
import QtQuick
import qs.config.theme
import qs.config.fonts

Item {
    id: root

    property string font: Fonts.varelaRound

    implicitWidth: 24
    implicitHeight: 500

    Text {
        anchors.centerIn: parent
        width: root.height
        rotation: -90
        text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "NA"
        color: Colors.palette.base06
        font {
            pixelSize: 20
            bold: true
            family: root.font
        }
        elide: Text.ElideLeft
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
