import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
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

    readonly property real _header: 18 + 8 + 1 + 8
    readonly property real _input: 72
    readonly property real _button: 36 + 8
    readonly property real _minContent: 80
    readonly property real _maxContent: 400

    implicitHeight: _header + inputBox.height + buttonsRow.height + 32 + 8

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
        }
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
        var f = fromCode === undefined ? "en" : fromCode
        var t = toCode === undefined ? "es" : toCode
        if (t === "en") {
            reverseBtn.flash = true
        } else {
            translateBtn.flash = true
        }
        procTranslate.command = [
            "bash", "-c", "exec \"$1\" \"$2\" \"$3\" \"$4\" \"$5\" \"$6\" 2>/dev/null || true",
            "bash", "/home/carlosm/.config/scripts/utilities/translate.py",
            "--from", f,
            "--to", t,
            text
        ]
        procTranslate.running = true
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
        id: procTranslate
        command: ["bash", "-c", "echo no text"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false
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
        radius: 10
        color: Colors.palette.base00
        border.color: "#7F" + Colors.palette.base04.slice(1) // Implementacion de alpha #AARRGGBB
        clip: true

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            Rectangle {
                id: inputBox
                width: parent.width
                height: _input
                radius: 8
                color: Colors.palette.base02

                TextArea {
                    id: textInput
                    anchors.fill: parent
                    anchors.margins: 8
                    placeholderText: "Text to translate…"
                    placeholderTextColor: Colors.palette.base03
                    color: Colors.palette.base05
                    font.pixelSize: 16
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

            Row {
                id: buttonsRow
                width: parent.width
                spacing: 8

                Column {
                    id: buttonCol
                    width: 32
                    spacing: 8

                    BarButtom {
                        id: translateBtn
                        iconText: "󰊿"
                        active: root.loading
                        onClicked: root.runTranslation()
                    }

                    BarButtom {
                        id: historyBtn
                        iconText: "󰋚"
                        active: root.historyVisible
                        onClicked: root.historyVisible = !root.historyVisible
                    }

                    BarButtom {
                        id: reverseBtn
                        iconText: "󰗊"
                        active: root.loading
                        onClicked: root.runTranslation("es", "en")
                    }
                }

                Item {
                    id: contentArea
                    width: parent.width - buttonCol.width - parent.spacing
                    height: {
                        if (root.loading) return _minContent
                        if (root.errorMsg !== "") {
                            var eh = errorText.implicitHeight + 16
                            return Math.max(_minContent, Math.min(150, eh))
                        }
                        if (root.output !== "") {
                            var th = outputText.implicitHeight + 16
                            return Math.max(_minContent, Math.min(_maxContent, th))
                        }
                        return _minContent
                    }

                    BusyIndicator {
                        anchors.centerIn: parent
                        running: root.loading
                        visible: root.loading
                    }

                    Text {
                        id: errorText
                        anchors.centerIn: parent
                        visible: !root.loading && root.errorMsg !== ""
                        text: root.errorMsg
                        color: Colors.palette.base08
                        font.pixelSize: 14
                        font.family: root.font
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }

                    Flickable {
                        id: flick
                        visible: !root.loading && root.output !== ""
                        anchors.fill: parent
                        clip: true
                        contentHeight: outputText.y + outputText.height
                        contentWidth: width

                        Text {
                            id: outputText
                            anchors.left: parent.left
                            anchors.right: parent.right
                            text: root.output
                            color: Colors.palette.base05
                            font.pixelSize: 16
                            font.family: root.font
                            wrapMode: Text.WordWrap
                            textFormat: Text.PlainText
                            lineHeight: 1.5
                        }
                    }

                    Rectangle {
                        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                        width: 6
                        visible: flick.visible && flick.contentHeight > flick.height
                        color: Colors.palette.base02
                        radius: 3

                        Rectangle {
                            y: (flick.visibleArea.yPosition / (1 - flick.visibleArea.heightRatio)) * (parent.height - height)
                            width: parent.width
                            height: flick.visibleArea.heightRatio * parent.height
                            radius: 3
                            color: Colors.palette.base04
                        }
                    }
                }
            }
        }
    }

    PopupWindow {
        id: historyPopup
        color: "transparent"
        visible: root.historyVisible
        width: 400
        implicitHeight: 300
        anchor.window: root
        anchor.rect.x: root.width - width
        anchor.rect.y: root.height

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: Colors.palette.base00
            border.color: "#7F" + Colors.palette.base04.slice(1) // Implementacion de alpha #AARRGGBB
            clip: true

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "History"
                    color: Colors.palette.base05
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    font.family: root.font
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Colors.palette.base03
                }

                Flickable {
                    width: parent.width
                    height: parent.height - 50
                    clip: true
                    contentHeight: histCol.height

                    Column {
                        id: histCol
                        width: parent.width
                        spacing: 4

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
                                        color: Colors.palette.base08
                                        font.pixelSize: 13
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
