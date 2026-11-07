pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import "../components"
import "../components/js/TimeShared.js" as TimeShared
import qs.config.theme

MenuLayout {
    id: root

    property int viewYear: mexicoNow.getFullYear()
    property int viewMonth: mexicoNow.getMonth()

    readonly property date mexicoNow: TimeShared.mexicoCityDate(clock.date)
    readonly property int daysInViewMonth: new Date(viewYear, viewMonth + 1, 0).getDate()
    readonly property int firstDayOfViewMonth: new Date(viewYear, viewMonth, 1).getDay()
    readonly property var monthNames: [
        qsTr("January"), qsTr("February"), qsTr("March"), qsTr("April"),
        qsTr("May"), qsTr("June"), qsTr("July"), qsTr("August"),
        qsTr("September"), qsTr("October"), qsTr("November"), qsTr("December")
    ]

    implicitWidth: 220
    implicitHeight: 270

    component NavButton: Rectangle {
        id: nav

        property string glyph
        signal clicked()

        width: 26
        height: 26
        radius: 6
        color: navMouse.containsMouse ? Colors.palette.base01 : "transparent"

        Text {
            anchors.centerIn: parent
            text: nav.glyph
            color: Colors.palette.base05
            font.pixelSize: 18
        }

        MouseArea {
            id: navMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: nav.clicked()
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    function changeMonth(delta) {
        var nextMonth = viewMonth + delta
        if (nextMonth < 0) {
            viewMonth = 11
            viewYear--
        } else if (nextMonth > 11) {
            viewMonth = 0
            viewYear++
        } else {
            viewMonth = nextMonth
        }
    }

    Row {
        width: parent.width
        height: 26
        spacing: 4

        NavButton {
            glyph: "‹"
            onClicked: root.changeMonth(-1)
        }

        Text {
            width: parent.width - 60
            height: parent.height
            text: root.monthNames[root.viewMonth].toUpperCase() + " " + root.viewYear
            color: Colors.palette.base05
            font.pixelSize: 14
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        NavButton {
            glyph: "›"
            onClicked: root.changeMonth(1)
        }
    }

    MenuSeparator {}

    Grid {
        id: weekdayHeader
        width: parent.width
        columns: 7
        columnSpacing: 2

        Repeater {
            model: [qsTr("S"), qsTr("M"), qsTr("T"), qsTr("W"), qsTr("T"), qsTr("F"), qsTr("S")]

            Text {
                required property string modelData

                width: 26
                height: 18
                text: modelData
                color: Colors.palette.base03
                font.pixelSize: 11
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Grid {
        id: daysGrid
        width: parent.width
        columns: 7
        rowSpacing: 2
        columnSpacing: 2

        Repeater {
            model: 42

            Rectangle {
                id: dayCell

                required property int index

                readonly property bool isDay: index >= root.firstDayOfViewMonth
                    && index < root.firstDayOfViewMonth + root.daysInViewMonth
                readonly property int dayNumber: index - root.firstDayOfViewMonth + 1
                readonly property bool isToday: isDay
                    && root.viewYear === root.mexicoNow.getFullYear()
                    && root.viewMonth === root.mexicoNow.getMonth()
                    && dayNumber === root.mexicoNow.getDate()

                width: 26
                height: 26
                radius: 6
                color: isToday
                    ? Colors.palette.base02
                    : (dayMouse.containsMouse && isDay ? Colors.palette.base01 : "transparent")
                border.color: isToday ? Colors.palette.base03 : "transparent"
                border.width: isToday ? 1 : 0

                Text {
                    anchors.centerIn: parent
                    text: dayCell.isDay ? dayCell.dayNumber : ""
                    color: Colors.palette.base05
                    font.pixelSize: 12
                    font.bold: dayCell.isToday
                }

                MouseArea {
                    id: dayMouse
                    anchors.fill: parent
                    hoverEnabled: dayCell.isDay
                    cursorShape: dayCell.isDay ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
        }
    }

    Text {
        width: parent.width
        text: Qt.formatDate(root.mexicoNow, "dddd, MMMM d, yyyy")
        color: Colors.palette.base04
        font.pixelSize: 12
        horizontalAlignment: Text.AlignHCenter
    }
}
