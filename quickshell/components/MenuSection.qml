import QtQuick
import qs.config.theme

Text {
    property string label: ""

    text: label
    color: Colors.palette.base03
    font.pixelSize: 11
    font.weight: Font.Bold
}
