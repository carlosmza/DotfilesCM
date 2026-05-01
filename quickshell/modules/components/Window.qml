import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls

Item {
    id: root
    // Angle in degrees; negative for counterclockwise
    property int rotationAngle: -90
    // Vertical offset in pixels applied after anchoring
    property int yOffset: 0
    // Maximum length for the window title text
    property int maxTitleLength: 40

    // sensible implicit size so parents can lay this out
    implicitWidth: 24
    implicitHeight: 200

    function truncateText(text, maxLength) {
        return text.length > maxLength ? text.substring(0, maxLength) + "..." : text
    }


    Text {
        id: titleText
        color: "white"
        font.pixelSize: 14
        font.bold: true
        anchors.centerIn: parent
        anchors.top: parent.bottom
        anchors.topMargin: 10
        rotation: root.rotationAngle
        transformOrigin: Item.Center
        y: root.yOffset
        elide: Text.ElideRight
        text: {
            var title = Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "NA"
            return truncateText(title, root.maxTitleLength)
        }

    }
}
