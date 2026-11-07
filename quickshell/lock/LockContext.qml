import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

Scope {
    id: root

    signal unlocked()

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false

    property string userName: (Quickshell.env("USER") || "").toString()
    property bool sessionActionsEnabled: true

    readonly property var sessionActions: [
        { key: "logout", label: "Cerrar sesión", icon: "\uF2F5", command: ["hyprctl", "dispatch", "exit"] },
        { key: "suspend", label: "Suspender", icon: "\uF186", command: ["systemctl", "suspend"] },
        { key: "reboot", label: "Reiniciar", icon: "\uF2F1", command: ["systemctl", "reboot"] },
        { key: "poweroff", label: "Apagar", icon: "\uF011", command: ["systemctl", "poweroff"] }
    ]

    function runSessionAction(action) {
        if (!root.sessionActionsEnabled || !action)
            return

        sessionProcess.command = action.command
        sessionProcess.running = true
    }

    onCurrentTextChanged: root.showFailure = false

    function tryUnlock() {
        if (root.currentText === "" || root.unlockInProgress)
            return

        root.unlockInProgress = true

        if (!pam.start())
            root.unlockInProgress = false
    }

    PamContext {
        id: pam

        configDirectory: "pam"
        config: "password.conf"

        onPamMessage: {
            if (this.responseRequired)
                this.respond(root.currentText)
        }

        onCompleted: function(result) {
            if (result === PamResult.Success) {
                root.unlocked()
            } else {
                root.currentText = ""
                root.showFailure = true
            }

            root.unlockInProgress = false
        }

        onError: function(error) {
            root.unlockInProgress = false
            root.showFailure = true
        }
    }

    Process {
        id: sessionProcess
        command: ["true"]
    }
}
