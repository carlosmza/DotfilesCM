import Quickshell
import Quickshell.Services.UPower
import QtQuick

Rectangle {
    id: root

    required property LockContext context

    property string wallpaperPath: "/home/carlosm/Pictures/Wallpapers/Jinx-arcane-sit-Dark.jpg"
    property color textColor: "#ffffff"
    property color failureColor: "#e64553"
    property color capsColor: "#f0b132"
    property string iconFont: "JetBrainsMono Nerd Font Mono"
    property bool capsLockOn: false

    readonly property real batteryCapacity: UPower.displayDevice ? UPower.displayDevice.percentage * 100 : 0
    readonly property bool batteryPlugged: !UPower.onBattery

    property string batteryIcon: {
        var icons = ["󰂃", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
        var lvl = Math.max(0, Math.min(100, Math.round(root.batteryCapacity)))
        return icons[Math.min(icons.length - 1, Math.floor(lvl * icons.length / 100))]
    }

    property color batteryColor: {
        if (root.batteryCapacity >= 99 && root.batteryPlugged)
            return "#00ff00"
        if (root.batteryCapacity < 99 && root.batteryPlugged)
            return "#4a9eff"
        if (root.batteryCapacity <= 20)
            return "#ff0000"
        return Qt.rgba(1, 1, 1, 0.8)
    }

    color: "#101018"
    opacity: 0

    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    Component.onCompleted: root.opacity = 1

    FontLoader {
        id: azedoFont
        source: Qt.resolvedUrl("fonts/02-Azedo-Bold.otf")
    }

    FontLoader {
        id: eliantoFont
        source: Qt.resolvedUrl("fonts/04-Elianto-Regular.otf")
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Image {
        anchors.fill: parent
        source: root.wallpaperPath
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
    }

    MouseArea {
        anchors.fill: parent
        onClicked: passwordInput.forceActiveFocus()
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.16
        spacing: 6

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: timeLabel.implicitWidth
            implicitHeight: timeLabel.implicitHeight

            Text {
                x: 2
                y: 2
                text: timeLabel.text
                font: timeLabel.font
                color: Qt.rgba(0, 0, 0, 0.5)
            }

            Text {
                id: timeLabel
                text: Qt.formatTime(clock.date, "HH:mm")
                font.family: eliantoFont.name
                font.pixelSize: 120
                color: root.textColor
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(clock.date, "dddd - dd MMMM yyyy").toUpperCase()
            font.family: eliantoFont.name
            font.pixelSize: 22
            font.letterSpacing: 2
            color: Qt.rgba(1, 1, 1, 0.85)
        }
    }

    Column {
        id: centerColumn

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.context.userName.toUpperCase()
            font.family: azedoFont.name
            font.pixelSize: 28
            font.letterSpacing: 4
            color: Qt.rgba(1, 1, 1, 0.9)
        }

        Column {
            id: authBlock

            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            transform: Translate { id: shakeOffset }

            Rectangle {
                id: inputFrame

                width: 380
                height: 50
                radius: 12
                color: Qt.rgba(0, 0, 0, 0.55)
                border.width: 1
                border.color: root.context.showFailure
                    ? root.failureColor
                    : passwordInput.activeFocus ? Qt.rgba(1, 1, 1, 0.65) : Qt.rgba(1, 1, 1, 0.3)
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: "Contraseña"
                    color: Qt.rgba(1, 1, 1, 0.4)
                    font.pixelSize: 16
                    visible: passwordInput.text.length === 0
                }

                TextInput {
                    id: passwordInput

                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    color: root.textColor
                    font.pixelSize: 17
                    selectionColor: Qt.rgba(1, 1, 1, 0.25)
                    selectedTextColor: root.textColor
                    focus: true
                    enabled: !root.context.unlockInProgress
                    inputMethodHints: Qt.ImhSensitiveData
                    selectByMouse: true

                    onTextChanged: root.context.currentText = text
                    onAccepted: root.context.tryUnlock()

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_CapsLock)
                            root.capsLockOn = !root.capsLockOn
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "CAPS LOCK"
                visible: root.capsLockOn
                color: root.capsColor
                font.family: eliantoFont.name
                font.pixelSize: 13
                font.letterSpacing: 3
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Contraseña incorrecta"
                visible: root.context.showFailure
                color: root.failureColor
                font.family: eliantoFont.name
                font.pixelSize: 14
            }
        }
    }

    Row {
        id: sessionRow

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 56
        spacing: 18

        Repeater {
            model: root.context.sessionActions

            delegate: Rectangle {
                required property var modelData

                width: 52
                height: 52
                radius: 12
                color: hoverArea.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(0, 0, 0, 0.5)
                border.width: 1
                border.color: hoverArea.containsMouse ? Qt.rgba(1, 1, 1, 0.5) : Qt.rgba(1, 1, 1, 0.15)
                opacity: root.context.sessionActionsEnabled ? 1 : 0.35
                scale: hoverArea.containsMouse ? 1.06 : 1

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    font.family: root.iconFont
                    font.pixelSize: 22
                    color: Qt.rgba(1, 1, 1, 0.9)
                }

                MouseArea {
                    id: hoverArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: root.context.sessionActionsEnabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: root.context.runSessionAction(modelData)
                }
            }
        }
    }

    Row {
        id: batteryRow

        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 48
        anchors.bottomMargin: 52
        spacing: 8
        visible: UPower.displayDevice !== null

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.batteryIcon
            font.family: root.iconFont
            font.pixelSize: 20
            color: root.batteryColor
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(root.batteryCapacity) + "%"
            font.family: eliantoFont.name
            font.pixelSize: 18
            color: root.batteryColor
        }
    }

    SequentialAnimation {
        id: shakeAnim

        NumberAnimation { target: shakeOffset; property: "x"; to: -10; duration: 45 }
        NumberAnimation { target: shakeOffset; property: "x"; to: 10; duration: 45 }
        NumberAnimation { target: shakeOffset; property: "x"; to: -6; duration: 45 }
        NumberAnimation { target: shakeOffset; property: "x"; to: 6; duration: 45 }
        NumberAnimation { target: shakeOffset; property: "x"; to: 0; duration: 45 }
    }

    Connections {
        target: root.context

        function onCurrentTextChanged() {
            if (passwordInput.text !== root.context.currentText)
                passwordInput.text = root.context.currentText
        }

        function onShowFailureChanged() {
            if (root.context.showFailure)
                shakeAnim.restart()
        }
    }
}
