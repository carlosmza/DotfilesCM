import Quickshell
import QtQuick

PopupWindow {
    id: root

    // El contenido se crea solo mientras el popup está visible
    // y se recrea en cada apertura.
    property Component contentComponent
    property bool open: false
    property var anchorWindow: null
    property int anchorX: 40
    property int anchorY: 0

    color: "transparent"
    visible: false

    anchor {
        window: root.anchorWindow
        rect.x: root.anchorX
        rect.y: root.anchorY
    }

    function show() {
        root.visible = true
        root.open = true
    }

    function close() {
        root.open = false
    }

    function toggle() {
        if (root.open)
            root.close()
        else
            root.show()
    }

    AnimateReveal {
        id: reveal
        anchors.fill: parent
        preset: AnimateReveal.SlideLeft
        open: root.open

        Loader {
            anchors.fill: parent
            active: root.visible
            enabled: root.open
            sourceComponent: root.contentComponent
        }

        // La transición de salida emite hidden() de forma fiable vía
        // onRunningChanged; onFinished no se emite dentro de Transitions.
        onHidden: root.visible = false
    }
}
