import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import qs.config.theme
import qs.config.fonts

PanelWindow {
    id: root
    anchors { top: true; right: true }
    margins { top: 50; right: 10 }

    color: "transparent"
    exclusiveZone: -1
    visible: false
    focusable: true
    implicitWidth: 400

    property string font: Fonts.varelaRound
    property string input: ""
    property string errorMsg: ""
    property string output: ""
    property bool loading: false
    property bool historyVisible: false
    property var history: []
    property string stage: ""
    property bool modelReady: true
    property string _langLabel: "EN → ES"

    readonly property real _header: 18 + 6 + 1 + 8
    readonly property real _footer: 14 + 8
    readonly property real _input: 96
    readonly property real _minContent: 80
    readonly property real _maxContent: 400

    readonly property string _statusText: {
        if (root.loading) return root.stage === "loading-model" ? "Cargando modelo…" : "Translating…"
        if (root.errorMsg !== "") return "No result"
        if (root.output !== "") return root.input.length + " → " + root.output.length + " chars"
        return _langLabel
    }

    implicitHeight: _header + inputBox.height + contentArea.height + _footer + 60

    Component.onCompleted: {
        var raw = ""
        try {
            raw = historyFile.text()
        } catch (e) {}
        if (raw === "") return
        try {
            root.history = JSON.parse(raw)
        } catch (e) {
            root.history = []
        }
    }

    onVisibleChanged: {
        if (visible) {
            textInput.forceActiveFocus()
            queryModelStatus()
        }
    }

    function queryModelStatus() {
        if (!procStatus.running) procStatus.running = true
    }

    function runTranslation(fromCode, toCode) {
        if (loading) return
        var text = textInput.text.trim()
        if (text === "") {
            errorMsg = "Write some text to translate."
            output = ""
            return
        }
        errorMsg = ""
        output = ""
        input = text
        loading = true
        stage = root.modelReady ? "translating" : "loading-model"
        slowTimer.restart()
        hangTimer.restart()
        var f = fromCode === undefined ? "en" : fromCode
        var t = toCode === undefined ? "es" : toCode
        _langLabel = f.toUpperCase() + " → " + t.toUpperCase()
        procTranslate.command = [
            "bash", "-c", "exec \"$1\" \"$2\" \"$3\" \"$4\" \"$5\" \"$6\" 2>/dev/null || true",
            "bash", "/home/carlosm/.config/scripts/utilities/translate.py",
            "--from", f,
            "--to", t,
            text
        ]
        procTranslate.running = true
        if (t === "en") {
            reverseBtn.flash = true
        } else {
            translateBtn.flash = true
        }
    }

    function close() {
        root.visible = false
        root.historyVisible = false
    }

    function saveHistory() {
        try {
            historyFile.setText(JSON.stringify(root.history, null, 2))
        } catch (e) {}
    }

    FileView {
        id: historyFile
        path: "/home/carlosm/.local/translate_history.json"
        blockLoading: true
        atomicWrites: true
    }

    Process {
        id: procStatus
        command: ["bash", "-c", "exec \"$1\" \"$2\" 2>/dev/null || true",
            "bash", "/home/carlosm/.config/scripts/utilities/translate.py",
            "--status"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.modelReady = (this.text.trim() === "ready")
            }
        }
    }

    Timer {
        id: slowTimer
        interval: 3000
        repeat: false
        onTriggered: {
            if (root.loading) root.stage = "loading-model"
        }
    }

    Timer {
        id: hangTimer
        interval: 10000
        repeat: false
        onTriggered: {
            if (root.loading) {
                root.loading = false
                root.stage = ""
                slowTimer.stop()
                if (root.errorMsg === "") {
                    root.errorMsg = "No translation found.\nCheck that the argos daemon is running."
                }
            }
        }
    }

    Process {
        id: procTranslate
        command: ["bash", "-c", "echo no text"]
        onExited: (exitCode, exitStatus) => {
            if (exitStatus !== 0 && root.loading) {
                root.loading = false
                root.stage = ""
                slowTimer.stop()
                hangTimer.stop()
                if (root.errorMsg === "") {
                    root.errorMsg = "No translation found.\nCheck that the argos daemon is running."
                }
            }
        }
        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false
                root.stage = ""
                slowTimer.stop()
                hangTimer.stop()
                var text = this.text.trim()
                if (text === "") {
                    if (root.errorMsg === "") {
                        root.errorMsg = "No translation found.\nCheck that the argos daemon is running."
                    }
                } else {
                    root.output = text
                    root.errorMsg = ""
                    root.history = [{
                        input: root.input,
                        output: text,
                        timestamp: new Date().toISOString()
                    }].concat(root.history).slice(0, 50)
                    root.saveHistory()
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Colors.palette.base00
        border.color: "#9F" + Colors.palette.base04.slice(1) // Implementacion de alpha #AARRGGBB
        clip: true

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                width: parent.width
                spacing: 8

                Text {
                    text: "󰊿"
                    color: Colors.palette.base0D
                    font.pixelSize: 16
                    font.family: root.font
                }

                Text {
                    text: "Translate"
                    color: Colors.palette.base05
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    font.family: root.font
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: langText.implicitWidth + 16
                    implicitHeight: langText.implicitHeight + 8
                    radius: 10
                    color: Colors.palette.base02

                    Text {
                        id: langText
                        anchors.centerIn: parent
                        text: root._langLabel
                        color: Colors.palette.base05
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        font.family: root.font
                    }
                }

                BarButton {
                    id: historyBtn
                    iconText: "󰋚"
                    active: root.historyVisible
                    onClicked: root.historyVisible = !root.historyVisible
                }
            }

            // Rectangle {
            //     width: parent.width
            //     height: 1
            //     color: Colors.palette.base02
            // }

            Rectangle {
                id: inputBox
                width: parent.width
                height: _input
                radius: 8
                color: Colors.palette.base02

                RowLayout {
                    id: inputHeader
                    x: 10
                    y: 8
                    width: parent.width - 20
                    spacing: 6

                    Rectangle {
                        width: 3
                        height: inputHeaderCol.height
                        radius: 2
                        color: Colors.palette.base0D
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Column {
                        id: inputHeaderCol
                        spacing: 2

                        Text {
                            text: "SOURCE"
                            color: Colors.palette.base04
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            font.family: root.font
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "Enter EN→ES · Ctrl+Enter ES→EN"
                        color: Colors.palette.base04
                        font.pixelSize: 10
                        font.family: root.font
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                TextArea {
                    id: textInput
                    anchors.fill: parent
                    anchors.topMargin: 26
                    anchors.leftMargin: 14
                    anchors.rightMargin: 10
                    anchors.bottomMargin: 8
                    placeholderText: "Text to translate…"
                    placeholderTextColor: Colors.palette.base05
                    color: Colors.palette.base03
                    font.pixelSize: 15
                    font.family: root.font
                    wrapMode: TextEdit.Wrap
                    selectByMouse: true

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            root.close()
                            event.accepted = true
                        } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                                   && !(event.modifiers & Qt.ShiftModifier)) {
                            if (event.modifiers & Qt.ControlModifier) {
                                root.runTranslation("es", "en")
                            } else {
                                root.runTranslation("en", "es")
                            }
                            event.accepted = true
                        }
                    }
                }
            }

            Item {
                id: contentArea
                width: parent.width
                height: {
                    if (root.loading) return _minContent
                    if (root.errorMsg !== "") {
                        var eh = errorCard.implicitHeight + 8
                        return Math.max(_minContent, Math.min(150, eh))
                    }
                    if (root.output !== "") {
                        var th = flickCol.implicitHeight + 8
                        return Math.max(_minContent, Math.min(_maxContent, th))
                    }
                    return _minContent
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 6
                    visible: root.loading

                    BusyIndicator {
                        anchors.horizontalCenter: parent.horizontalCenter
                        running: root.loading
                        visible: root.loading
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.stage === "loading-model" ? "Cargando modelo de Argos…" : "Traduciendo…"
                        color: root.stage === "loading-model" ? Colors.palette.base0A : Colors.palette.base03
                        font.pixelSize: 12
                        font.family: root.font
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: root.stage === "loading-model"
                        text: "Solo tarda la primera vez tras arrancar"
                        color: Colors.palette.base03
                        font.pixelSize: 11
                        font.family: root.font
                    }
                }

                Rectangle {
                    id: errorCard
                    anchors.centerIn: parent
                    visible: !root.loading && root.errorMsg !== ""
                    width: parent.width
                    implicitHeight: errorInner.implicitHeight + 20
                    radius: 8
                    color: "#1A" + Colors.palette.base08.slice(1)
                    border.color: "#4D" + Colors.palette.base08.slice(1)
                    border.width: 1

                    Row {
                        id: errorInner
                        anchors.centerIn: parent
                        width: parent.width - 20
                        spacing: 8

                        Text {
                            text: "󰷌"
                            color: Colors.palette.base08
                            font.pixelSize: 16
                            font.family: root.font
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id: errorText
                            width: parent.width - 24
                            text: root.errorMsg
                            color: Colors.palette.base08
                            font.pixelSize: 13
                            font.family: root.font
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                Flickable {
                    id: flick
                    visible: !root.loading && root.output !== ""
                    anchors.fill: parent
                    anchors.rightMargin: 10
                    clip: true
                    contentHeight: flickCol.implicitHeight
                    contentWidth: width

                    Column {
                        id: flickCol
                        width: flick.width
                        spacing: 8

                        Item {
                            width: parent.width
                            height: 16

                            // Rectangle {
                            //     anchors.verticalCenter: parent.verticalCenter
                            //     x: 0
                            //     width: parent.width / 2 - 14
                            //     height: 1
                            //     color: Colors.palette.base02
                            // }
                            //
                            // Text {
                            //     anchors.centerIn: parent
                            //     text: "󰁔"
                            //     color: Colors.palette.base03
                            //     font.pixelSize: 12
                            // }
                            //
                            // Rectangle {
                            //     anchors.verticalCenter: parent.verticalCenter
                            //     x: parent.width / 2 + 14
                            //     width: parent.width / 2 - 14
                            //     height: 1
                            //     color: Colors.palette.base02
                            // }
                        }

                        Text {
                            id: outputText
                            width: parent.width
                            text: root.output
                            color: Colors.palette.base05
                            font.pixelSize: 16
                            font.family: root.font
                            wrapMode: Text.WordWrap
                            textFormat: Text.PlainText
                            lineHeight: 1.4
                        }
                    }
                }

                Rectangle {
                    id: scrollTrack
                    anchors {
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: 6
                    visible: flick.visible && flick.contentHeight > flick.height
                    color: Colors.palette.base01
                    radius: 3

                    Rectangle {
                        y: flick.visibleArea.heightRatio >= 1 ? 0 : (flick.visibleArea.yPosition / (1 - flick.visibleArea.heightRatio)) * (parent.height - height)
                        width: parent.width
                        height: Math.max(20, flick.visibleArea.heightRatio * parent.height)
                        radius: 3
                        color: Colors.palette.base04
                    }
                }
            }

            RowLayout {
                width: parent.width
                spacing: 8

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    Layout.alignment: Qt.AlignVCenter
                    color: root.loading ? Colors.palette.base0A : (root.errorMsg !== "" ? Colors.palette.base08 : Colors.palette.base0B)
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Text {
                    text: _statusText
                    color: Colors.palette.base04
                    font.pixelSize: 13
                    font.family: root.font
                    Layout.alignment: Qt.AlignVCenter
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                BarButton {
                    id: reverseBtn
                    iconText: "󰗊"
                    active: root.loading
                    onClicked: root.runTranslation("es", "en")
                }

                BarButton {
                    id: translateBtn
                    iconText: "󰊿"
                    active: root.loading
                    onClicked: root.runTranslation()
                }
            }
        }
    }

    PopupWindow {
        id: historyPopup
        color: "transparent"
        visible: root.historyVisible
        implicitWidth: 400
        implicitHeight: 300
        anchor.window: root
        anchor.rect.x: root.width - width
        anchor.rect.y: root.height

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: Colors.palette.base00
            border.color: "#7F" + Colors.palette.base04.slice(1) // Implementacion de alpha #AARRGGBB
            clip: true

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "󰋚"
                        color: Colors.palette.base0D
                        font.pixelSize: 16
                        font.family: root.font
                    }

                    Text {
                        text: "History"
                        color: Colors.palette.base05
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        font.family: root.font
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        implicitWidth: histCountText.implicitWidth + 12
                        implicitHeight: histCountText.implicitHeight + 6
                        radius: 8
                        color: Colors.palette.base02

                        Text {
                            id: histCountText
                            anchors.centerIn: parent
                            text: root.history.length + ""
                            color: Colors.palette.base04
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            font.family: root.font
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Colors.palette.base02
                }

                Flickable {
                    width: parent.width
                    height: parent.height - 56
                    clip: true
                    contentHeight: histCol.height

                    Column {
                        id: histCol
                        width: parent.width
                        spacing: 4

                        Text {
                            width: parent.width
                            visible: root.history.length === 0
                            text: "No history yet"
                            color: Colors.palette.base03
                            font.pixelSize: 13
                            font.family: root.font
                            horizontalAlignment: Text.AlignHCenter
                            topPadding: 24
                        }

                        Repeater {
                            model: root.history

                            delegate: Rectangle {
                                width: parent.width
                                height: entryCol.height + 16
                                radius: 8
                                color: hma.containsMouse ? Colors.palette.base02 : "transparent"
                                Behavior on color { ColorAnimation { duration: 150 } }

                                Column {
                                    id: entryCol
                                    width: parent.width - 16
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        top: parent.top
                                    }
                                    anchors.topMargin: 8
                                    spacing: 2

                                    Text {
                                        width: parent.width
                                        text: modelData.input
                                        color: Colors.palette.base05
                                        font.pixelSize: 13
                                        font.italic: true
                                        font.family: root.font
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: parent.width
                                        text: modelData.output
                                        color: Colors.palette.base05
                                        font.pixelSize: 13
                                        font.family: root.font
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 3
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    id: hma
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.output = modelData.output
                                        root.errorMsg = ""
                                        textInput.text = modelData.input
                                        root.historyVisible = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
