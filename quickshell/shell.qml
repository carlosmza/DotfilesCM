import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick 2.15
import qs.config.theme
import "./ui/layout/"
import "./ui/popups/"
import "./ui/widgets/"
import "./ui/components/"
import "./dev/"
import "./services/"

ShellRoot {
    LeftBar {}
    ClockWidget {}
    BrightnessPopup {}
    VolumePopup {}
    ThemeSelector {
        id: themeSelector
    }
    IpcHandler {
        target: "colores"
        function recargar(): void {
            Quickshell.reload(false)
        }
    }
    IpcHandler {
        target: "theme"
        function toggle(): void {
            themeSelector.visible = !themeSelector.visible
        }
        function show(): void {
            themeSelector.visible = true
        }
        function hide(): void {
            themeSelector.visible = false
        }
    }
    IpcHandler {
        target: "wallpapers"
        function toggle(): void {
            wallpaperSelector.visible = !wallpaperSelector.visible
        }
        function show(): void {
            wallpaperSelector.visible = true
        }
        function hide(): void {
            wallpaperSelector.visible = false
        }
    }
    WallpaperSelector {
        id: wallpaperSelector
    }
}
