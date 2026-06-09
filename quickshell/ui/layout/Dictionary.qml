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
        bottom: true
    }

    margins {
        left: 10
        top: 200
        bottom: 400
        right: 15
    }

    implicitWidth: 400
    color: "transparent"
    exclusiveZone: -1
    visible: false

    property string font: Fonts.varelaRound
    property string output: ""
    property bool loading: false
    property string errorMsg: ""

    onVisibleChanged: {
        if (visible) {
            runTranslation()
        }
    }

    function runTranslation() {
        if (loading) return
        loading = true
        errorMsg = ""
        output = ""
        procTranslate.running = true
    }

    Process {
        id: procTranslate
        command: ["bash", "-c", "/home/carlosm/.config/scripts/utilities/dictionary.py 2>/dev/null || true"]
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
                text: "Dictionary"
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
                width: parent.width
                height: parent.height - 60

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

                Flickable {
                    id: flick
                    visible: !root.loading && root.output !== ""
                    anchors.fill: parent
                    clip: true
                    contentHeight: outputText.height
                    contentWidth: width

                    Text {
                        id: outputText
                        text: root.output
                        color: Colors.palette.base05
                        font.pixelSize: 15
                        font.family: "monospace"
                        width: flick.width
                        wrapMode: Text.WordWrap
                        textFormat: Text.PlainText
                        leftPadding: 4
                        rightPadding: 4
                        bottomPadding: 8
                        lineHeight: 1.5
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

    // Keys.onPressed: function (event) {
    //     if (event.key === Qt.Key_Escape) {
    //         root.visible = false
    //         event.accepted = true
    //     }
    // }
}
