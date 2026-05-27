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
        right: 10
    }

    implicitWidth: 500
    color: "transparent"
    exclusiveZone: -1
    visible: false

    property string font: Fonts.varelaRound
    property string input: ""
    property string output: ""
    property bool loading: false
    property string errorMsg: ""

    implicitHeight: Math.max(100, Math.min(
        120
        + (root.input !== "" ? hiddenInput.contentHeight : 0)
        + (root.output !== "" ? hiddenOutput.contentHeight : 0)
    , 600))

    Text {
        id: hiddenInput
        visible: false
        font.family: root.font
        font.pixelSize: 16
        font.weight: Font.Bold
        text: root.input
        width: root.implicitWidth - 32
        wrapMode: Text.WordWrap
    }

    Text {
        id: hiddenOutput
        visible: false
        font.family: "monospace"
        font.pixelSize: 13
        text: root.output
        width: root.implicitWidth - 32
        wrapMode: Text.WordWrap
    }

    onVisibleChanged: {
        if (visible) {
            runTranslation()
        }
    }

    function runTranslation() {
        if (loading) return
        loading = true
        errorMsg = ""
        input = ""
        output = ""
        procSelection.running = true
        procTranslate.running = true
    }

    Process {
        id: procSelection
        command: ["bash", "-c", "wl-paste -p"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false
                // var text = this.text.remplace (/\n/g,'a')
                // var text = this.text.trim()
                var text = this.text.replace(/\n/g, " ").trim().slice(0, 500)

                if (text === "") {
                    root.errorMsg = "No word selection.\nSelect a word and try again."
                } else {
                    root.input = text
                }
            }
        }
    }

    Process {
        id: procTranslate
        command: ["bash", "-c", "/home/carlosm/.config/scripts/utilities/translate.py 2>/dev/null || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false
                var text = this.text.trim()
                if (text === "") {
                    root.errorMsg = "No translation found.\nSelect a word and try again."
                } else {
                    root.output = text
                }
            }
        }
    }

    Rectangle {
        color: Colors.palette.base00
        anchors.fill: parent
        radius: 20
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

            // Scrollable content area
            Item {
                width: parent.width
                height: parent.height - 50 // header + separator + spacings

                Flickable {
                    id: flick
                    anchors.fill: parent
                    clip: true
                    contentWidth: width
                    contentHeight: contentColumn.height
                    visible: !root.loading && (root.input !== "" || root.output !== "")

                    Column {
                        id: contentColumn
                        width: parent.width
                        spacing: 8

                        Text {
                            id: inputText
                            text: root.input
                            color: Colors.palette.base0D
                            font.pixelSize: 15
                            font.weight: Font.Bold
                            font.family: root.font
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            visible: root.output !== ""
                            color: Colors.palette.base03
                        }

                        Text {
                            id: outputText
                            text: root.output
                            color: Colors.palette.base05
                            font.pixelSize: 13
                            font.family: "monospace"
                            width: parent.width
                            wrapMode: Text.WordWrap
                            textFormat: Text.PlainText
                            lineHeight: 1.4
                            bottomPadding: 8
                            padding: 4
                        }
                    }
                }

                BusyIndicator {
                    anchors.centerIn: parent
                    running: root.loading
                    visible: root.loading
                }

                Text {
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

                // Custom scrollbar
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
                        height: Math.max(20, flick.visibleArea.heightRatio * parent.height)
                        radius: 3
                        color: Colors.palette.base04
                    }
                }
            }
        }
    }
}
