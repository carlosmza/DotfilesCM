import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: root
    visible: false

    property var _node: Pipewire.defaultAudioSink
    property bool _booted: false

    property real volumeValue: 0
    property int threshold: 80

    signal valueChanged()

    PwObjectTracker {
        objects: root._node ? [root._node] : []
    }

    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() { root._sync() }
    }

    Connections {
        target: root._node ? root._node.audio : null
        function onVolumesChanged() { root._sync() }
        function onMutedChanged() { root._sync() }
    }

    Component.onCompleted: Qt.callLater(() => root._booted = true)

    function _sync() {
        const audio = root._node && root._node.audio ? root._node.audio : null
        root.volumeValue = audio ? Math.round(audio.volume * 100) : 0
        if (root._booted) root.valueChanged()
    }
}