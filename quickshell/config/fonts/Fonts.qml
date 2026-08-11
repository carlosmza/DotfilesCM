pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // Cargadores de fuentes
    FontLoader { id: font_anurati;           source: Qt.resolvedUrl("01-Anurati.otf") }
    FontLoader { id: font_azedo;             source: Qt.resolvedUrl("02-Azedo-Bold.otf") }
    FontLoader { id: font_beyno;             source: Qt.resolvedUrl("03-BEYNO.otf") }
    FontLoader { id: font_elianto;           source: Qt.resolvedUrl("04-Elianto-Regular.otf") }
    FontLoader { id: font_instrument_serif;  source: Qt.resolvedUrl("05-InstrumentSerif-Regular.ttf") }
    FontLoader { id: font_lato_italic;       source: Qt.resolvedUrl("06-Lato-Italic.ttf") }
    FontLoader { id: font_poppins;           source: Qt.resolvedUrl("07-Poppins.ttf") }
    FontLoader { id: font_varela_round;      source: Qt.resolvedUrl("08-VarelaRound-Regular.ttf") }

    // Exposición de nombres de fuente como propiedades de solo lectura
    // Puedes elegir una activa por defecto, por ejemplo BEYNO
    readonly property string activeTopFont: font_azedo.name
    readonly property string activeDownFont: font_azedo.name

    readonly property string anurati:          font_anurati.name
    readonly property string azedoBold:        font_azedo.name
    readonly property string beyno:            font_beyno.name
    readonly property string elianto:          font_elianto.name
    readonly property string instrumentSerif:  font_instrument_serif.name
    readonly property string latoItalic:       font_lato_italic.name
    readonly property string poppins:          font_poppins.name
    readonly property string varelaRound:      font_varela_round.name
}
