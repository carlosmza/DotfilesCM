import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.config.theme
import qs.config.fonts

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property int value: -1

    property string summary: ""
    property string body: ""
    property string appName: ""
    property string appIcon: ""
    property int urgency: 0

    property int duration: 1200

    property bool showing: false

    signal expired()

    implicitWidth: Math.max(content.implicitWidth + 28, 200)
    implicitHeight: content.implicitHeight + 20

    function show() {
        showing = true
        hideTimer.stop()
        if (root.duration > 0)
            hideTimer.restart()
    }

    function hide() {
        showing = false
        hideTimer.stop()
    }

    color: Colors.palette.base01
    border.color: "#7F" + Colors.palette.base04.slice(1) // Implementacion de alpha #AARRGGBB
    radius: 8

    opacity: showing ? 1.0 : 0.0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation { duration: 400 }
    }

    Timer {
        id: hideTimer
        interval: root.duration
        repeat: false
        onTriggered: {
            root.showing = false
            root.expired()
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.hide()
            root.expired()
        }
    }

    RowLayout {
        id: content
        anchors.fill: parent
        anchors { leftMargin: 14; topMargin: 10; rightMargin: 14; bottomMargin: 10 }
        spacing: 10

        Item {
            id: leading
            implicitWidth: 24
            implicitHeight: 24
            Layout.alignment: Qt.AlignVCenter
            visible: root.icon !== "" || root.appIcon !== ""

            Text {
                anchors.centerIn: parent
                text: root.icon
                color: Colors.palette.base0D
                font.pixelSize: 14
                font.family: Fonts.varelaRound
                visible: root.icon !== ""
            }

            IconImage {
                anchors.fill: parent
                source: root.icon === "" ? root.appIcon : ""
                visible: root.icon === "" && root.appIcon !== ""
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.label !== "" ? root.label : root.summary
                color: Colors.palette.base05
                font.pixelSize: 14
                font.family: Fonts.varelaRound
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                visible: root.body !== ""
                text: root.body
                color: Colors.palette.base04
                font.pixelSize: 12
                font.family: Fonts.varelaRound
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }

        Text {
            visible: root.value >= 0
            text: root.value + " %"
            color: Colors.palette.base06
            font.pixelSize: 12
            font.weight: Font.Bold
            font.family: Fonts.varelaRound
            Layout.alignment: Qt.AlignVCenter
        }
    }
}