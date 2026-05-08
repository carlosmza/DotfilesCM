import Quickshell
import Quickshell.Io
import QtQuick
import qs.config.theme
import qs.config.fonts

Item {
    id: root
    property string timeStr: "00:00"
    property string font: Fonts.varelaRound
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
        color: Colors.palette.base06
        font {
            pixelSize: 17
            bold: true
            family: root.font
        }
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Text {
        id: minutesText
        text: root.timeStr && root.timeStr.indexOf(":") !== -1 ? root.timeStr.split(":")[1] : "00"
        color: Colors.palette.base06
        font {
            pixelSize: 17
            bold: true
            family: root.font
        }
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
