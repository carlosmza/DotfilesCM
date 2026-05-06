import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    id: root
    FileView {
      path: "/home/carlosm/test.json"

      // when changes are made on disk, reload the file's content
      watchChanges: true
      onFileChanged: reload()

      // when changes are made to properties in the adapter, save them
      onAdapterUpdated: writeAdapter()

      JsonAdapter {
        id: ja
        property string myStringProperty: "default value"
        onMyStringPropertyChanged: {
          console.log("myStringProperty was changed via qml or on disk")
        }
        property string color1: "#999999"
        onColor1Changed: {
          console.log("color1 was changed via qml or on disk")
        }

        property list<string> stringList: [ "default", "value" ]

        property JsonObject subObject: JsonObject {
          property string subObjectProperty: "default value"
          onSubObjectPropertyChanged: console.log("same as above")
        }

        // works the same way as subObject
        property var inlineJson: { "a": "b" }
      }
    }
    PanelWindow {
        implicitWidth: 100
        implicitHeight: 200
        anchors.right: true
        color: ja.color1

        Text {
            text: ja.myStringProperty + "\n" + ja.inlineJson.a + "\n" + ja.color1
        }
    }
}
