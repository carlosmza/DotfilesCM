import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import qs.config.theme
import qs.config.fonts

PanelWindow {
    id: root
    anchors {
        top: true
        right: true
    }

    margins {
        top: 10
        right: 15
    }

    color: "transparent"
    exclusiveZone: -1
    visible: false

    property string font: Fonts.varelaRound
    property string input: ""
    property string output: ""
    property bool loading: false
    property string errorMsg: ""
    property bool _fromCliphist: false

    readonly property real _header: 16 + 20 + 8 + 1 + 8
    readonly property real _footer: 16
    readonly property real _minContent: 80
    readonly property real _maxContent: 400
    readonly property real _minWidth: 280
    readonly property real _maxWidth: 600

    implicitWidth: Math.max(_minWidth, Math.min(Math.max(
        inputText.implicitWidth,
        outputText.implicitWidth,
        errorText.implicitWidth
    ) + 48, _maxWidth))
    implicitHeight: _header + contentArea.height + _footer

    onVisibleChanged: {
        if (visible) {
            runTranslation()
        }
    }

    property bool _gotSelection: false
    property bool _gotTranslation: false

    function runTranslation() {
        if (loading) return
        _gotSelection = false
        _gotTranslation = false
        loading = true
        errorMsg = ""
        output = ""
        input = ""
        procSelection.running = true
        procTranslate.running = true
    }

    Process {
        id: procSelection
        command: ["bash", "-c", "wl-paste -p"]
        stdout: StdioCollector {
            onStreamFinished: {
                var text = this.text.trim()
                if (text !== "") {
                    root._gotSelection = true
                    root._fromCliphist = false
                    root.input = text
                } else {
                    procCliphist.running = true
                }
                if (root._gotTranslation) root.loading = false
            }
        }
    }

    Process {
        id: procCliphist
        command: ["bash", "-c", "cliphist list | head -1 | cliphist decode"]
        stdout: StdioCollector {
            onStreamFinished: {
                root._gotSelection = true
                var text = this.text.trim()
                if (text !== "") {
                    root._fromCliphist = true
                    root.input = text
                    root.errorMsg = ""
                } else if (root.errorMsg === "") {
                    root.errorMsg = "No word selection.\nSelect a word and try again."
                }
                if (root._gotTranslation) root.loading = false
            }
        }
    }

    Process {
        id: procTranslate
        command: ["bash", "-c", "/home/carlosm/.config/scripts/utilities/translate.py 2>/dev/null || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                root._gotTranslation = true
                var text = this.text.trim()
                if (text === "") {
                    if (root.errorMsg === "") {
                        root.errorMsg = "No translation found.\nSelect a word and try again."
                    }
                } else {
                    root.output = text
                    root.errorMsg = ""
                }
                if (root._gotSelection) root.loading = false
            }
        }
    }

    Rectangle {
        color: Colors.palette.base00
        anchors.fill: parent
        radius: 0
        clip: true

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            Text {
                text: "Translate"
                color: Colors.palette.base05
                font.pixelSize: 18
                font.weight: Font.Bold
                font.family: root.font
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Colors.palette.base03
            }

            Item {
                id: contentArea
                width: parent.width
                height: {
                    if (root.loading) return _minContent
                    if (root.errorMsg !== "") {
                        var eh = errorText.implicitHeight + 16
                        return Math.max(_minContent, Math.min(150, eh))
                    }
                    if (root.output !== "") {
                        var th = inputText.implicitHeight + outputText.implicitHeight + 16
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
                        id: inputText
                        text: (root._fromCliphist ? "  " : "") + root.input + "\n"
                        color: Colors.palette.base07
                        font.pixelSize: 15
                        font.family: root.font
                        width: flick.width
                        wrapMode: Text.WordWrap
                        textFormat: Text.PlainText
                    }
                    Text {
                        id: outputText
                        text: root.output
                        color: Colors.palette.base05
                        font.pixelSize: 15
                        font.family: root.font
                        y: inputText.height
                        width: flick.width
                        wrapMode: Text.WordWrap
                        textFormat: Text.PlainText
                    }
                }

                Rectangle {
                    anchors {
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
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
