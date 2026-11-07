import Quickshell
import QtQuick
import Quickshell.Widgets
import qs.config.theme
import qs.config.fonts
import "../components"

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    color: "transparent"
    exclusiveZone: -1
    focusable: true
    visible: false

    property string query: ""
    property var allApps: []
    property var filteredApps: []
    property bool open: false

    function loadApps() {
        var apps = []
        var entries = DesktopEntries.applications.values
        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i]
            if (entry.noDisplay || !entry.name)
                continue

            apps.push({
                entry: entry,
                name: entry.name,
                genericName: entry.genericName || "",
                icon: entry.icon || "application-x-executable",
                searchText: (entry.name + " " + (entry.genericName || "") + " "
                    + (entry.keywords || []).join(" ")).toLowerCase()
            })
        }

        apps.sort(function(a, b) {
            return a.name.localeCompare(b.name)
        })
        root.allApps = apps
        root.updateResults()
    }

    function fuzzyScore(app, term) {
        var name = app.name.toLowerCase()
        if (name === term)
            return 1000
        if (name.indexOf(term) === 0)
            return 800
        if (new RegExp("(^|\\s)" + term.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")).test(name))
            return 650
        if (app.searchText.indexOf(term) !== -1)
            return 500

        var cursor = 0
        var first = -1
        var matched = 0
        for (var i = 0; i < name.length && cursor < term.length; i++) {
            if (name[i] === term[cursor]) {
                if (first < 0)
                    first = i
                cursor++
                matched++
            }
        }
        return cursor === term.length ? 100 + matched * 2 - first : -1
    }

    function updateResults() {
        var term = root.query.trim().toLowerCase()
        if (!term) {
            root.filteredApps = root.allApps
            return
        }

        var matches = []
        for (var i = 0; i < root.allApps.length; i++) {
            var app = root.allApps[i]
            var score = root.fuzzyScore(app, term)
            if (score >= 0)
                matches.push({ app: app, score: score })
        }
        matches.sort(function(a, b) {
            return b.score - a.score || a.app.name.localeCompare(b.app.name)
        })
        root.filteredApps = matches.map(function(match) { return match.app })
    }

    function showLauncher() {
        root.query = ""
        root.updateResults()
        root.visible = true
        root.open = true
        searchInput.forceActiveFocus()
    }

    function hideLauncher() {
        root.open = false
        closeTimer.restart()
    }

    function toggleLauncher() {
        if (root.visible && root.open)
            hideLauncher()
        else
            showLauncher()
    }

    function launchCurrent() {
        if (appList.currentIndex < 0 || appList.currentIndex >= root.filteredApps.length)
            return
        root.filteredApps[appList.currentIndex].entry.execute()
        root.hideLauncher()
    }

    function moveSelection(delta) {
        if (!root.filteredApps.length)
            return
        var next = appList.currentIndex + delta
        if (next < 0)
            next = root.filteredApps.length - 1
        if (next >= root.filteredApps.length)
            next = 0
        appList.currentIndex = next
        appList.positionViewAtIndex(next, ListView.Contain)
    }

    Component.onCompleted: root.loadApps()

    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() { root.loadApps() }
    }

    onQueryChanged: root.updateResults()
    onFilteredAppsChanged: {
        if (!root.filteredApps.length)
            appList.currentIndex = -1
        else if (appList.currentIndex < 0 || appList.currentIndex >= root.filteredApps.length)
            appList.currentIndex = 0
    }

    Timer {
        id: closeTimer
        interval: 180
        onTriggered: {
            if (!root.open)
                root.visible = false
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Colors.palette.base00, 0.62)
        opacity: root.open ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

        MouseArea {
            anchors.fill: parent
            onClicked: root.hideLauncher()
        }
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: 480
        height: 540
        color: Colors.palette.base00
        border.color: Colors.palette.base02
        border.width: 2
        radius: 15
        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.96
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked: mouse.accepted = true
        }

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            Rectangle {
                width: parent.width
                height: 44
                radius: 10
                color: Colors.palette.base01

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                    text: ""
                    color: Colors.palette.base03
                    font.pixelSize: 16
                }

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 40
                        right: parent.right
                        rightMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                    text: qsTr("Search apps...")
                    color: Colors.palette.base03
                    font.pixelSize: 16
                    font.family: Fonts.varelaRound
                    visible: searchInput.text === ""
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                TextInput {
                    id: searchInput
                    anchors {
                        left: parent.left
                        leftMargin: 40
                        right: parent.right
                        rightMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                    color: Colors.palette.base05
                    selectionColor: Colors.palette.base0D
                    font.pixelSize: 16
                    font.family: Fonts.varelaRound
                    clip: true
                    selectByMouse: true
                    text: root.query
                    onTextChanged: root.query = text

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Down) {
                            root.moveSelection(1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            root.moveSelection(-1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.launchCurrent()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            if (root.query !== "")
                                searchInput.clear()
                            else
                                root.hideLauncher()
                            event.accepted = true
                        } else if (event.key === Qt.Key_F5) {
                            root.loadApps()
                            event.accepted = true
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Colors.palette.base03
            }

            ListView {
                id: appList
                width: parent.width
                height: parent.height - 92
                model: root.filteredApps
                currentIndex: root.filteredApps.length ? 0 : -1
                spacing: 3
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                delegate: LauncherItem {
                    required property var modelData
                    width: appList.width
                    entry: modelData.entry
                    appName: modelData.name
                    genericName: modelData.genericName
                    iconName: modelData.icon
                    selected: ListView.isCurrentItem
                    onHovered: appList.currentIndex = index
                    onActivated: root.launchCurrent()
                }

                highlight: Rectangle {
                    visible: false
                }
            }

            Text {
                width: parent.width
                height: 18
                text: root.filteredApps.length
                    ? qsTr("%1 applications").arg(root.filteredApps.length)
                    : qsTr("No applications found")
                color: Colors.palette.base04
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
