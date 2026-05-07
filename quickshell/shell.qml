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

ShellRoot {
    LeftBar {}
    ClockWidget {}
    BrightnessPopup {}
    VolumePopup {}
    // Popup {}
    // DevReadJson {}
    // DevBox {}
    IpcHandler {
        target: "colores" // Nombre único para identificar este handler

        // Función que se llamará desde el script
        function recargar(): void {
            // Reload suave: intenta reusar las ventanas existentes
            Quickshell.reload(false)
        }
    }
}
