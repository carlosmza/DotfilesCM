-- Keybinds — DotfilesCM

local var = require("lua.variables")
local mainMod = var.mainMod

-- Apps
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(var.terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(var.menu))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(var.fileExplorer))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(var.browser))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd( "systemctl --user start argos-daemon.service && " .. var.pdfViewer))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprshot -m region -o /home/carlosm/Pictures/Screenshots -f \"Screenshot-From-$(date +%Y-%m-%d_%H-%M-%S).png\""))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -p 'History:' -theme ~/.config/rofi/menus/clipboard.rasi | cliphist decode | wl-copy"))

-- Theme and display
-- hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("/home/carlosm/.config/scripts/themes/theme-switcher.sh"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("quickshell ipc call theme toggle"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("quickshell ipc call wallpapers toggle"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("/home/carlosm/.config/scripts/system/display-switcher.sh"))

-- Lock screen
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("hyprlock"))

-- Power
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("/home/carlosm/.config/scripts/system/power-menu.sh"))

-- Utilities
-- hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("/home/carlosm/.config/scripts/utilities/argos-client.sh"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("/home/carlosm/noqs.sh"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("/home/carlosm/.config/scripts/utilities/traduction-es-en.sh"))
-- hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("/home/carlosm/.config/scripts/utilities/dictionary-en-en.sh"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("/home/carlosm/.config/scripts/utilities/2lyrics-pdf.py"))
hl.bind(mainMod .. " +  D", hl.dsp.exec_cmd("/home/carlosm/.config/scripts/utilities/translate.py"))
hl.bind(mainMod .. " +  D", hl.dsp.exec_cmd("quickshell ipc call dictionary toggle"))
hl.bind(mainMod .. " +  E", hl.dsp.exec_cmd("quickshell ipc call translate toggle"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("quickshell ipc call translate-window toggle"))

-- Scratchpad
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
-- ytm
hl.bind(mainMod .. " + M", function()
    hl.dispatch(hl.dsp.workspace.toggle_special("ytm"))
end)

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

hl.bind(mainMod .. " + R", function ()
  -- Cambiar a flotante (toggle)
  hl.dispatch(hl.dsp.window.float({ action = "toggle" }))

  -- -- Redimensionar a 1400x900
  hl.dispatch(hl.dsp.window.resize({
    -- size = { 1400, 900 },   -- usa size = {w, h} como en la sintaxis nueva
		x = -600,
    y = -370,
    relative = true
    -- opcional: relative = false,
  }))
end)
