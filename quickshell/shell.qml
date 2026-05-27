import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick 2.15
import qs.config.theme
import "./ui/layout/"
import "./ui/popups/"
import "./ui/widgets/"
import "./ui/components/"
import "./ui/lock/"
import "./dev/"
import "./services/"

ShellRoot {
    LeftBar {}
    ClockWidget {}
    BrightnessPopup {}
    VolumePopup {}
    Dictionary { id: dictionary }
    ThemeSelector { id: themeSelector }
    WallpaperSelector { id: wallpaperSelector }
    Translate { id: translate }
    // LockScreen { id: lockScreen }
    
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
    IpcHandler {
        target: "dictionary"
        function toggle(): void {
            dictionary.visible = !dictionary.visible
        }
        function show(): void {
            dictionary.visible = true
        }
        function hide(): void {
            dictionary.visible = false
        }
    }
    IpcHandler {
        target: "translate"
        function toggle(): void {
            translate.visible = !translate.visible
        }
        function show(): void {
            translate.visible = true
        }
        function hide(): void {
            translate.visible = false
        }
    }
    IpcHandler {
        target: "lock"
        function toggle(): void {
            if (!lockScreen.visible) {
                lockScreen.lock()
            }
        }
        function lock(): void {
            lockScreen.lock()
        }
        function unlock(): void {
            // Only password auth can unlock
        }
    }
}
