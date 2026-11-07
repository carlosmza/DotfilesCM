import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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
    focusable: true

    property string font: Fonts.varelaRound
    property string input: ""
    property string output: ""
    property bool loading: false
    property string errorMsg: ""
    property bool _fromCliphist: false

    readonly property real _header: 22 + 6 + 1 + 8
    readonly property real _footer: 14 + 8
    readonly property real _minContent: 80
    readonly property real _maxContent: 400
    readonly property real _minWidth: 280
    readonly property real _maxWidth: 600
    readonly property string _sourceLabel: root._fromCliphist ? "Cliphist" : "Selection"
    readonly property string _statusText: {
        if (root.loading) return "Translating…"
        if (root.errorMsg !== "") return "No result"
        if (root.output !== "") return _sourceLabel + " · " + root.input.length + " → " + root.output.length + " chars"
        return _sourceLabel
    }

    implicitWidth: 380
    implicitHeight: _header + contentArea.height + _footer + 24

    onVisibleChanged: {
        if (visible) {
            runTranslation()
            keyGrabber.forceActiveFocus()
        }
    }

    Item {
        id: keyGrabber
        focus: true
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                root.visible = false
                event.accepted = true
            }
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
        radius: 12
        border.color: "#7F" + Colors.palette.base04.slice(1)
        border.width: 1
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
                        text: "EN → ES"
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
                    spacing: 8
                    visible: root.loading

                    BusyIndicator {
                        anchors.horizontalCenter: parent.horizontalCenter
                        running: root.loading
                        visible: root.loading
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Translating…"
                        color: Colors.palette.base03
                        font.pixelSize: 12
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

                        Rectangle {
                            width: parent.width
                            implicitHeight: sourceInner.implicitHeight + 20
                            radius: 8
                            color: Colors.palette.base02

                            Row {
                                id: sourceInner
                                width: parent.width - 16
                                anchors.centerIn: parent
                                spacing: 8

                                Rectangle {
                                    width: 3
                                    height: sourceCol.height
                                    radius: 2
                                    color: Colors.palette.base0D
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    id: sourceCol
                                    width: parent.width - 11
                                    spacing: 4

                                    Row {
                                        width: parent.width
                                        spacing: 6

                                        Text {
                                            text: "SOURCE"
                                            color: Colors.palette.base04
                                            font.pixelSize: 10
                                            font.weight: Font.Bold
                                            font.family: root.font
                                        }

                                        Item { width: 2; height: 1 }

                                        Rectangle {
                                            implicitWidth: srcBadge.implicitWidth + 12
                                            implicitHeight: srcBadge.implicitHeight + 4
                                            radius: 8
                                            color: Colors.palette.base01

                                            Text {
                                                id: srcBadge
                                                anchors.centerIn: parent
                                                text: (root._fromCliphist ? "󰅍 " : "󰉨 ") + _sourceLabel
                                                color: Colors.palette.base04
                                                font.pixelSize: 12
                                                font.family: root.font
                                            }
                                        }
                                    }

                                    Text {
                                        id: inputText
                                        width: parent.width
                                        text: root.input
                                        color: Colors.palette.base05
                                        font.pixelSize: 15
                                        font.italic: true
                                        font.family: root.font
                                        wrapMode: Text.WordWrap
                                        textFormat: Text.PlainText
                                        maximumLineCount: 4
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }

                        Item {
                            width: parent.width
                            height: 16

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                x: 0
                                width: parent.width / 2 - 14
                                height: 1
                                color: Colors.palette.base02
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰁔"
                                color: Colors.palette.base03
                                font.pixelSize: 12
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                x: parent.width / 2 + 14
                                width: parent.width / 2 - 14
                                height: 1
                                color: Colors.palette.base02
                            }
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

            Row {
                width: parent.width
                spacing: 6

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.loading ? Colors.palette.base0A : (root.errorMsg !== "" ? Colors.palette.base08 : Colors.palette.base0B)
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Text {
                    text: _statusText
                    color: Colors.palette.base04
                    font.pixelSize: 13
                    font.family: root.font
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    width: parent.width - 12
                }
            }
        }
    }
}
