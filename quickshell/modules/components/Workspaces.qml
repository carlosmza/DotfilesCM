import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property int count: 6

    implicitWidth: 30
    implicitHeight: 50

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
                    color: isActive? '#ff63a4' : '#67719b'
                    font { pixelSize: 14; bold: true }
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}

