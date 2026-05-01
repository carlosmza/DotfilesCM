import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    property string timeStr: "00:00"
    implicitWidth: 40
    implicitHeight: 300

    Column {
      id: vColumn
      anchors.centerIn: parent
      spacing: 2
      width: parent.width

      Text {
        id: hoursText
        text: root.timeStr && root.timeStr.indexOf(":") !== -1 ? root.timeStr.split(":")[0] : "00"
        color: "white"
        font { pixelSize: 16; bold: true }
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Text {
        id: minutesText
        text: root.timeStr && root.timeStr.indexOf(":") !== -1 ? root.timeStr.split(":")[1] : "00"
        color: "white"
        font { pixelSize: 16; bold: true }
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
      }
    }

  Timer {
      interval: 1000
      running: true
      repeat: true

      onTriggered: {
          let now = new Date()
          let h = now.getHours().toString().padStart(2, "0")
          let m = now.getMinutes().toString().padStart(2, "0")
          root.timeStr = h + ":" + m
      }
  }
}
