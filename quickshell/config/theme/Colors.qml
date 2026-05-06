// Colors.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string name: "no name"
    property string slug: "no slug"
    property string variant: "no variant"
    property JsonObject palette: JsonObject {
        property string base00: "#faf4eD"
        property string base01: "#657a8a"
        property string base02: "#f2e9de"
        property string base03: "#9893a5"
        property string base04: "#797593"
        property string base05: "#575279"
        property string base06: "#575279"
        property string base07: "#cecacd"
        property string base08: "#b4637a"
        property string base09: "#ea9d34"
        property string base0A: "#d7827e"
        property string base0B: "#286983"
        property string base0C: "#56949f"
        property string base0D: "#907aa9"
        property string base0E: "#ea9d34"
        property string base0F: "#cecacd"
    }
    FileView {
        path: "/home/carlosm/.config/quickshell/config/theme/current.json"
        // path: "/home/carlosm/test.json"
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoaded: {
            root._copyConfigToRoot()  // Poblar las propiedades del Singleton
        }
        JsonAdapter {
            id: ja
            property string name: "no name"
            property string slug: "no slug"
            property string variant: "no variant"
            property JsonObject palette: JsonObject {
                property string base00: "#faf4eD"
                property string base01: "#657a8a"
                property string base02: "#f2e9de"
                property string base03: "#9893a5"
                property string base04: "#797593"
                property string base05: "#575279"
                property string base06: "#575279"
                property string base07: "#cecacd"
                property string base08: "#b4637a"
                property string base09: "#ea9d34"
                property string base0A: "#d7827e"
                property string base0B: "#286983"
                property string base0C: "#56949f"
                property string base0D: "#907aa9"
                property string base0E: "#ea9d34"
                property string base0F: "#cecacd"
            }
        }
    }

    function _copyConfigToRoot() {
        root.name = ja.name
        root.slug = ja.slug
        root.variant = ja.variant
        root.palette.base00 = ja.palette.base00
        root.palette.base01 = ja.palette.base01
        root.palette.base02 = ja.palette.base02
        root.palette.base03 = ja.palette.base03
        root.palette.base04 = ja.palette.base04
        root.palette.base05 = ja.palette.base05
        root.palette.base06 = ja.palette.base06
        root.palette.base07 = ja.palette.base07
        root.palette.base08 = ja.palette.base08
        root.palette.base09 = ja.palette.base09
        root.palette.base0A = ja.palette.base0A
        root.palette.base0B = ja.palette.base0B
        root.palette.base0C = ja.palette.base0C
        root.palette.base0D = ja.palette.base0D
        root.palette.base0E = ja.palette.base0E
        root.palette.base0F = ja.palette.base0F
    }
    
}
