import QtQuick
import Quickshell

ShellRoot {
    LockContext {
        id: lockContext

        sessionActionsEnabled: false
        onUnlocked: Qt.quit()
    }

    FloatingWindow {
        implicitWidth: 1280
        implicitHeight: 720

        LockSurface {
            anchors.fill: parent
            context: lockContext
        }
    }

    Connections {
        target: Quickshell

        function onLastWindowClosed() {
            Qt.quit()
        }
    }
}
