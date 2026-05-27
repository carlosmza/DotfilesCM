import Quickshell.Io.File
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs.config.theme
import qs.config.fonts

PanelWindow {
    id: root
    visible: false
    color: "#000000"
    anchors { top: true; left: true; right: true; bottom: true }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property string font: Fonts.azedoBold
    property string user: ""
    property bool authenticating: false

    Component.onCompleted: {
        userProc.command = ["bash", "-c", "whoami"]
        userProc.running = true
    }

    onVisibleChanged: {
        if (visible) {
            captureAndBlur()
            Qt.callLater(function() {
                passwordInput.forceActiveFocus()
            })
        } else {
            blurFallback.stop()
        }
    }

    File {
        id: debugLog
        path: "/tmp/lockscreen_debug.log"
        mode: File.WriteOnly
    }
    // Capture all key events to prevent passing through to windows behind
    // Keys.onPressed: {
    //     event.accepted = true
    // }
    // Keys.onReleased: {
    //     event.accepted = true
    // }

    function captureAndBlur() {
        loadingOverlay.visible = true
        blurFallback.start()
        blurProc.command = ["bash", "-c", "grim - | magick - -blur 0x48 /tmp/lockscreen_blurred.png"]
        blurProc.running = true
    }

    function lock() {
        loginctlProc.command = ["bash", "-c", "loginctl lock-session"]
        loginctlProc.running = true
        root.visible = true
    }

    function authenticate() {
        // if (root.authenticating || root.user === "") return
        if (root.authenticating || root.user === "") {
            debugLog.write("Authenticate blocked: authenticating=" + root.authenticating + " user='" + root.user + "'\n")
            return
        }
        root.authenticating = true
        debugLog.write("Attempting auth as user='" + root.user + "' with password='" + passwordInput.text + "'\n")
        // authProc.command = ["bash", "-c", "read -r PASS && printf '%s\\n' \"$PASS\" | /sbin/unix_chkpwd carlosm lock 2>/dev/null && echo OK || echo FAIL"]
        // authProc.command = ["bash", "-c", "read -r PASS && printf '%s\\n' \"$PASS\" | /sbin/unix_chkpwd " + root.user + " lock 2>/dev/null && echo OK || echo FAIL"]
        // authProc.command = ["bash", "-c", "read -r PASS && printf '%s\\n' \"$PASS\" | /sbin/unix_chkpwd \"" + root.user + "\" 2>/dev/null && echo OK || echo FAIL" ]
        authProc.command = ["bash", "-c", "read -r PASS && printf '%s\\n' \"$PASS\" | /usr/bin/unix_chkpwd \"" + root.user + "\" 2>/dev/null && echo OK || echo FAIL" ]
        authProc.running = true
        authProc.write(passwordInput.text + "\n")
    }

    Process {
        id: userProc
        command: ["bash"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.user = this.text.trim()
            }
        }
    }

    Process {
        id: blurProc
        command: ["bash"]
        stdout: StdioCollector {
            onStreamFinished: {
                blurFallback.stop()
                loadingOverlay.visible = false
                bgImage.source = "file:///tmp/lockscreen_blurred.png"
            }
        }
    }

    Process {
        id: loginctlProc
        command: ["bash"]
    }

    Timer {
        id: blurFallback
        interval: 3000
        onTriggered: {
            loadingOverlay.visible = false
        }
    }

    Process {
        id: authProc
        command: ["bash"]
        stdinEnabled: true
        stdout: StdioCollector {
            onStreamFinished: {
                    debugLog.write("authProc stdout: '" + this.text.trim() + "'\n")
                root.authenticating = false
                var result = this.text.trim()
                if (result === "OK") {
                    root.visible = false
                    passwordInput.text = ""
                    errorText.visible = false
                } else {
                    errorText.visible = true
                    passwordInput.text = ""
                    passwordInput.forceActiveFocus()
                }
            }
            stderr: StdioCollector {
                onStreamFinished: {
                    debugLog.write("authProc stderr: '" + this.text.trim() + "'\n")
                }
            }
            onTerminated: {
                debugLog.write("authProc finished with exit code: " + exitCode + "\n")
                root.authenticating = false
                var result = stdoutCollector.text.trim() // necesitas una referencia al collector, mejor usar binding
                // como los collectors son inline, mejor guardar resultado del stdout al terminar
            }
        }
    }

    Timer {
        id: clockTimer
        interval: 1000
        running: root.visible
        repeat: true
        onTriggered: clockText.text = new Date().toLocaleTimeString(Qt.locale(), "HH:mm")
    }

    Timer {
        id: dateTimer
        interval: 60000
        running: root.visible
        repeat: true
        onTriggered: dateText.text = new Date().toLocaleDateString(Qt.locale(), "dddd, d MMMM")
    }

    Image {
        id: bgImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: ""
    }

    Rectangle {
        id: loadingOverlay
        anchors.fill: parent
        color: "#000000"
        visible: false
    }

    Rectangle {
        anchors.fill: parent
        color: "#88000000"
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8

        Text {
            id: clockText
            text: new Date().toLocaleTimeString(Qt.locale(), "HH:mm")
            color: "white"
            font {
                pixelSize: 72
                weight: Font.Light
                family: root.font
            }
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            id: dateText
            text: new Date().toLocaleDateString(Qt.locale(), "dddd, d MMMM")
            color: "#dddddd"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Item { height: 40; Layout.fillWidth: true }

        Text {
            text: root.user
            color: "#cccccc"
            font {
                pixelSize: 18
                family: root.font
            }
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            id: inputBg
            width: 280
            height: 44
            radius: 22
            color: "#33ffffff"
            border.color: "#66ffffff"
            border.width: 1
            Layout.alignment: Qt.AlignHCenter

            TextInput {
                id: passwordInput
                anchors {
                    fill: parent
                    leftMargin: 20
                    rightMargin: 20
                }
                color: "white"
                font.pixelSize: 16
                echoMode: TextInput.Password
                passwordCharacter: "●"
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter

                onAccepted: root.authenticate()
            }
        }

        Text {
            id: errorText
            text: "Wrong password"
            color: Colors.palette.base08
            font.pixelSize: 13
            visible: false
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // Battery indicator - bottom right
    Rectangle {
        id: batteryBox
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 24
        }
        height: 34
        radius: 17
        color: "#44ffffff"
        visible: UPower.displayDevice !== null

        Row {
            id: batteryRow
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: {
                    var pct = UPower.displayDevice?.percentage * 100 || 0
                    if (UPower.onBattery === false) return "󰂄"
                    if (pct <= 20) return "󱃍"
                    return "󰁹"
                }
                color: "white"
                font.pixelSize: 14
            }

            Text {
                text: {
                    var pct = Math.round(UPower.displayDevice?.percentage * 100 || 0)
                    var status = UPower.onBattery === false ? " Charging" : ""
                    return pct + "%" + status
                }
                color: "white"
                font.pixelSize: 13
            }
        }

        width: batteryRow.implicitWidth + 28
    }

    // Full-screen click blocker (prevents interaction with windows behind)
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: false
        onClicked: passwordInput.forceActiveFocus()
    }
}
