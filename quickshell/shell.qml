import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland
import QtQuick
import qs.config.theme
import qs.services

import "./modules/"
import "./components/"
// import "./.dev/"

ShellRoot {
    id: root

    // === Desktop profile detection (XDG_CURRENT_DESKTOP, e.g. "Hyprland", "KDE", "a:b") ===
    readonly property string desktop: (Quickshell.env("XDG_CURRENT_DESKTOP") || "").toString().toLowerCase()
    readonly property var tokens: desktop.split(":")
    readonly property bool isHyprland: tokens.indexOf("hyprland") !== -1
    // Hyprland wins if both tokens ever appear together
    readonly property bool isKde: !isHyprland && (tokens.indexOf("kde") !== -1 || tokens.indexOf("plasma") !== -1)

    // === Hyprland profile: the full current shell ===
    Loader {
        id: leftBarLoader
        active: root.isHyprland
        asynchronous: true
        sourceComponent: leftBarComp
    }
    Component {
        id: leftBarComp
        LeftBar {}
    }

    // Loader {
    //     id: clockWidgetLoader
    //     active: root.isHyprland || root.isKde
    //     asynchronous: true
    //     sourceComponent: clockWidgetComp
    // }
    // Component {
    //     id: clockWidgetComp
    //     ClockWidget {}
    // }

    Loader {
        id: launcherAppsLoader
        active: root.isHyprland
        asynchronous: true
        sourceComponent: launcherAppsComp
    }
    Component {
        id: launcherAppsComp
        LauncherApps {}
    }

    Loader {
        id: powerMenuLoader
        active: root.isHyprland
        asynchronous: true
        sourceComponent: powerMenuComp
    }
    Component {
        id: powerMenuComp
        PowerMenu {}
    }

    Loader {
        id: monitorMenuLoader
        active: root.isHyprland
        asynchronous: true
        sourceComponent: monitorMenuComp
    }
    Component {
        id: monitorMenuComp
        MonitorMenu {}
    }

    Loader {
        id: systemNotificationsLoader
        active: root.isHyprland
        asynchronous: true
        sourceComponent: systemNotificationsComp
    }
    Component {
        id: systemNotificationsComp
        SystemNotifications {}
    }

    Loader {
        id: brightnessPopupLoader
        active: root.isHyprland
        asynchronous: true
        sourceComponent: brightnessPopupComp
    }
    Component {
        id: brightnessPopupComp
        BrightnessPopup {}
    }

    Loader {
        id: volumePopupLoader
        active: root.isHyprland
        asynchronous: true
        sourceComponent: volumePopupComp
    }
    Component {
        id: volumePopupComp
        VolumePopup {}
    }

    Loader {
        id: dictionaryLoader
        active: root.isHyprland || root.isKde
        asynchronous: true
        sourceComponent: dictionaryComp
    }
    Component {
        id: dictionaryComp
        Dictionary {}
    }

    Loader {
        id: themeSelectorLoader
        active: root.isHyprland || root.isKde
        asynchronous: true
        sourceComponent: themeSelectorComp
    }
    Component {
        id: themeSelectorComp
        ThemeSelector {}
    }

    Loader {
        id: wallpaperSelectorLoader
        active: root.isHyprland
        asynchronous: true
        sourceComponent: wallpaperSelectorComp
    }
    Component {
        id: wallpaperSelectorComp
        WallpaperSelector {}
    }

    Loader {
        id: translateLoader
        active: root.isHyprland || root.isKde
        asynchronous: true
        sourceComponent: translateComp
    }
    Component {
        id: translateComp
        Translate {}
    }

    Loader {
        id: translateWindowLoader
        active: root.isHyprland || root.isKde
        asynchronous: true
        sourceComponent: translateWindowComp
    }
    Component {
        id: translateWindowComp
        TranslateWindow {}
    }


    Loader {
        id: notificationServerLoader
        active: root.isHyprland
        asynchronous: false
        sourceComponent: notificationServerComp
    }
    Component {
        id: notificationServerComp
        NotificationServer {
            keepOnReload: false
            bodySupported: true
            bodyMarkupSupported: true
            onNotification: notif => {
                notif.tracked = true
                Notifications.addSystem(notif)
            }
        }
    }

    // === KDE profile: intentionally empty, add Plasma modules here with active: root.isKde ===
    // Any other desktop (or unset XDG_CURRENT_DESKTOP): no Loader is active, nothing loads.
    //
    // === IpcHandler ===

    IpcHandler {
        target: "notify"
        function mostrar(icon: string, label: string, value: int, duration: int): void {
            if (root.isHyprland)
                Notifications.mostrar(icon, label, value, duration)
        }
        function dismissAll(): void {
            if (root.isHyprland)
                Notifications.dismissAll()
        }
        function toggleDnd(): void {
            if (root.isHyprland)
                Notifications.toggleDnd()
        }
    }

    IpcHandler {
        target: "colores"
        function recargar(): void {
            Quickshell.reload(false)
        }
    }
    IpcHandler {
        target: "launcher"
        function toggle(): void {
            if (launcherAppsLoader.status === Loader.Ready)
                launcherAppsLoader.item.toggleLauncher()
        }
        function show(): void {
            if (launcherAppsLoader.status === Loader.Ready)
                launcherAppsLoader.item.showLauncher()
        }
        function hide(): void {
            if (launcherAppsLoader.status === Loader.Ready)
                launcherAppsLoader.item.hideLauncher()
        }
    }
    IpcHandler {
        target: "power"
        function toggle(): void {
            if (powerMenuLoader.status === Loader.Ready)
                powerMenuLoader.item.toggleMenu()
        }
        function show(): void {
            if (powerMenuLoader.status === Loader.Ready)
                powerMenuLoader.item.showMenu()
        }
        function hide(): void {
            if (powerMenuLoader.status === Loader.Ready)
                powerMenuLoader.item.hideMenu()
        }
    }
    IpcHandler {
        target: "display"
        function toggle(): void {
            if (monitorMenuLoader.status === Loader.Ready)
                monitorMenuLoader.item.toggleMenu()
        }
        function show(): void {
            if (monitorMenuLoader.status === Loader.Ready)
                monitorMenuLoader.item.showMenu()
        }
        function hide(): void {
            if (monitorMenuLoader.status === Loader.Ready)
                monitorMenuLoader.item.hideMenu()
        }
    }
    IpcHandler {
        target: "brillo"
        function mostrar(): void {
            if (brightnessPopupLoader.status === Loader.Ready)
                brightnessPopupLoader.item.mostrar()
        }
    }
    IpcHandler {
        target: "theme"
        function toggle(): void {
            if (themeSelectorLoader.status === Loader.Ready)
                themeSelectorLoader.item.visible = !themeSelectorLoader.item.visible
        }
        function show(): void {
            if (themeSelectorLoader.status === Loader.Ready)
                themeSelectorLoader.item.visible = true
        }
        function hide(): void {
            if (themeSelectorLoader.status === Loader.Ready)
                themeSelectorLoader.item.visible = false
        }
    }
    IpcHandler {
        target: "wallpapers"
        function toggle(): void {
            if (wallpaperSelectorLoader.status === Loader.Ready)
                wallpaperSelectorLoader.item.visible = !wallpaperSelectorLoader.item.visible
        }
        function show(): void {
            if (wallpaperSelectorLoader.status === Loader.Ready)
                wallpaperSelectorLoader.item.visible = true
        }
        function hide(): void {
            if (wallpaperSelectorLoader.status === Loader.Ready)
                wallpaperSelectorLoader.item.visible = false
        }
    }
    IpcHandler {
        target: "dictionary"
        function toggle(): void {
            if (dictionaryLoader.status === Loader.Ready)
                dictionaryLoader.item.visible = !dictionaryLoader.item.visible
        }
        function show(): void {
            if (dictionaryLoader.status === Loader.Ready)
                dictionaryLoader.item.visible = true
        }
        function hide(): void {
            if (dictionaryLoader.status === Loader.Ready)
                dictionaryLoader.item.visible = false
        }
    }
    IpcHandler {
        target: "translate"
        function toggle(): void {
            if (translateLoader.status === Loader.Ready)
                translateLoader.item.visible = !translateLoader.item.visible
        }
        function show(): void {
            if (translateLoader.status === Loader.Ready)
                translateLoader.item.visible = true
        }
        function hide(): void {
            if (translateLoader.status === Loader.Ready)
                translateLoader.item.visible = false
        }
    }
    IpcHandler {
        target: "translate-window"
        function toggle(): void {
            if (translateWindowLoader.status === Loader.Ready)
                translateWindowLoader.item.visible = !translateWindowLoader.item.visible
        }
        function show(): void {
            if (translateWindowLoader.status === Loader.Ready)
                translateWindowLoader.item.visible = true
        }
        function hide(): void {
            if (translateWindowLoader.status === Loader.Ready)
                translateWindowLoader.item.visible = false
        }
    }
}
