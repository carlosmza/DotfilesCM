import QtQuick
import qs.config.theme

Item {
    id: root
    implicitWidth: 32
    implicitHeight: 32

    property string iconText: ""
    property bool active: false
    property bool bgEnable: true

    property bool flash: false
    property color flashColor: Colors.palette.base03
    property int flashDuration: 400

    readonly property alias hovered: hoverHandler.hovered

    signal clicked()

    onFlashChanged: {
        if (flash)
            flashAnim.restart()
    }

    NumberAnimation {
        id: flashAnim
        target: flashOverlay
        property: "opacity"
        from: 0.7
        to: 0
        duration: root.flashDuration
        easing.type: Easing.OutQuad
        onFinished: root.flash = false
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: root.active
            ? Colors.palette.base02
            : (root.hovered && root.bgEnable ? Colors.palette.base01 : "transparent")
        radius: 6
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.iconText
        color: Colors.palette.base05
        font.pixelSize: 20
        visible: root.iconText !== ""
    }

    Rectangle {
        id: flashOverlay
        anchors.fill: parent
        radius: 6
        color: root.flashColor
        opacity: 0
        visible: root.flash
    }

    HoverHandler {
        id: hoverHandler
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

}
