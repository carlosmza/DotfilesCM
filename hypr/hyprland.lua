-- Hyprland Lua config — DotfilesCM
-- Docs: https://wiki.hypr.land/Configuring/Start/

local theme = require("lua.themes.current")
local palette = theme.palette

-- Apps
local terminal = "foot"
local browser = "zen-browser"
local fileExplorer = "nautilus"
local pdfViewer = "okular"
local menu = "rofi -show drun -theme ~/.config/rofi/layouts/list-apps.rasi"

-- Touchpad
local touchpadFingers = 3
local touchpadFingersMore = 4

-- Blur
local blurEnabled = true
local blurSpecialWs = true
local blurSize = 8
local blurPasses = 2
local blurXray = false

-- Shadow
local shadowEnabled = false
local shadowRange = 10
local shadowRenderPower = 10
local shadowColor = "rgba(" .. palette.base00 .. "7F)"
local shadowInactiveColor = "rgba(" .. palette.base01 .. "7F)"

-- Window
local windowActiveOpacity = 0.98
local windowInactiveOpacity = 0.95
local windowRounding = 10
local windowRoundingPower = 4
local windowBorderSize = 5
local activeWindowBorderColour = "rgba(" .. palette.base0D .. "FF)"
local inactiveWindowBorderColour = "rgba(" .. palette.base02 .. "7F)"
local windowGapsIn = {5, 5, 5, 5}
local windowGapsOut = {5, 5, 5, 5}

-- Misc
local volumeStep = 5
local cursorTheme = "sweet-cursors"
local cursorSize = 12

-- Keybind prefixes (documentation only)
local mainMod = "SUPER"

-- =============================================================================
-- Monitors
-- =============================================================================
hl.monitor({ output = "eDP-1",    mode = "1920x1080@60",  position = "0x0",    scale = "1" })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@100", position = "1920x0", scale = "1" })

hl.workspace_rule({ workspace = "1", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1" })

-- =============================================================================
-- Environment variables
-- =============================================================================
-- hl.env("XCURSOR_SIZE", "24")
-- hl.env("XCURSOR_THEME", cursorTheme)
-- hl.env("XCURSOR_SIZE", tostring(cursorSize))

-- =============================================================================
-- Core config
-- =============================================================================
hl.config({
    general = {
        layout = "dwindle",
        allow_tearing = false,
        gaps_in = windowGapsIn,
        gaps_out = windowGapsOut,
        border_size = windowBorderSize,
        resize_on_border = true,
        col = {
            active_border = activeWindowBorderColour,
            inactive_border = inactiveWindowBorderColour,
        },
    },

    decoration = {
        rounding = windowRounding,
        rounding_power = windowRoundingPower,
        active_opacity = windowActiveOpacity,
        inactive_opacity = windowInactiveOpacity,
        shadow = {
            enabled = shadowEnabled,
            range = shadowRange,
            render_power = shadowRenderPower,
            color = shadowColor,
            color_inactive = shadowInactiveColor,
        },
        blur = {
            enabled = blurEnabled,
            size = blurSize,
            special = blurSpecialWs,
            passes = blurPasses,
            new_optimizations = true,
            ignore_opacity = true,
            xray = blurXray,
        },
    },

    input = {
        repeat_delay = 200,
        repeat_rate = 50,
        accel_profile = "flat",
        kb_layout = "latam",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
        },
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
    },
})

-- Layouts
hl.config({
    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = true,
    },
})

-- =============================================================================
-- Animations
-- =============================================================================
hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("specialWorkSwitch",  { type = "bezier", points = { {0.05, 0.7}, {0.1, 1} } })
hl.curve("emphasizedAccel",    { type = "bezier", points = { {0.3, 0},   {0.8, 0.15} } })
hl.curve("emphasizedDecel",    { type = "bezier", points = { {0.05, 0.7}, {0.1, 1} } })
hl.curve("standard",           { type = "bezier", points = { {0.2, 0},   {0, 1} } })

hl.animation({ leaf = "layersIn",          enabled = true, speed = 5,  bezier = "emphasizedDecel",  style = "slide" })
hl.animation({ leaf = "layersOut",         enabled = true, speed = 4,  bezier = "emphasizedAccel",  style = "slide" })
hl.animation({ leaf = "fadeLayers",        enabled = true, speed = 5,  bezier = "standard" })
hl.animation({ leaf = "windowsIn",         enabled = true, speed = 5,  bezier = "emphasizedDecel" })
hl.animation({ leaf = "windowsOut",        enabled = true, speed = 3,  bezier = "emphasizedAccel" })
hl.animation({ leaf = "windowsMove",       enabled = true, speed = 6,  bezier = "standard" })
hl.animation({ leaf = "workspaces",        enabled = true, speed = 5,  bezier = "standard" })
hl.animation({ leaf = "specialWorkspace",  enabled = true, speed = 4,  bezier = "specialWorkSwitch", style = "slidefadevert 15%" })
hl.animation({ leaf = "fade",              enabled = true, speed = 6,  bezier = "standard" })
hl.animation({ leaf = "fadeDim",           enabled = true, speed = 6,  bezier = "standard" })
hl.animation({ leaf = "border",            enabled = true, speed = 6,  bezier = "standard" })

-- =============================================================================
-- Window rules
-- =============================================================================
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})

-- =============================================================================
-- Gestures
-- =============================================================================
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "up",          scale = 1.0, action = "fullscreen" })
-- hl.gesture({
--     fingers = 3,
--     direction = "down",
--     dispatcher = true,
--     action = "exec",
--     cmd = "/usr/bin/makoctl dismiss -a",
-- })

-- Per-device config
hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- =============================================================================
-- Autostart
-- =============================================================================
hl.on("hyprland.start", function()
    hl.exec_cmd("qs")
    hl.exec_cmd("/usr/bin/awww-daemon")
    hl.exec_cmd("kitty --listen-on unix:/tmp/kitty.sock --single-instance")
    hl.exec_cmd("wl-paste --watch cliphist store")
end)

hl.exec_cmd("/home/carlosm/.config/scripts/system/refresh-display.sh")

-- =============================================================================
-- Keybinds
-- =============================================================================
-- Apps
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("bash -c '/home/carlosm/.config/scripts/system/kitty-launch.sh 2> /tmp/kitty-debug.log'"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(fileExplorer))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(pdfViewer))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprshot -m region -o /home/carlosm/Pictures/Screenshots/ -f \"Screenshot-From-$(date +%Y-%m-%d_%H-%M-%S).png\""))

-- Theme and display
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("/home/carlosm/.config/scripts/themes/theme-switcher.sh"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("/home/carlosm/.config/scripts/system/display-switcher.sh"))

-- Power
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("/home/carlosm/.config/scripts/system/power-menu.sh"))

-- Utilities
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("/home/carlosm/.config/scripts/utilities/argos-client.sh"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("/home/carlosm/.config/scripts/utilities/traduction-es-en.sh"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("/home/carlosm/.config/scripts/utilities/dictionary-en-en.sh"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("/home/carlosm/.config/scripts/utilities/2lyrics-pdf.py"))

-- Scratchpad
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Focus movement
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Workspace switching
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Window management
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),         { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),        { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                     { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
