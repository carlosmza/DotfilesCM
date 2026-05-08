import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.config.theme

Item {
    id: root
    property int count: 6

    implicitWidth: 31
    implicitHeight: 20

    property string font: Fonts.varelaRound

    Loader {
        anchors.fill: parent
        anchors.margins: 5
        sourceComponent: verticalComp
    }

    Component {
        id: verticalComp
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 10

            Repeater {
                model: root.count
                Text {
                    property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                    text: index + 1
                    color: isActive? Colors.palette.base0D : Colors.palette.base07
                    font {
                        pixelSize: 17
                        bold: true
                        family: root.font
                    }
                    horizontalAlignment: Text.AlignHCenter
                }
            }

        }
    }
}

