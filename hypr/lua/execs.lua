-- Autostart — DotfilesCM

hl.on("hyprland.start", function()
    hl.exec_cmd("qs")
    hl.exec_cmd("/usr/bin/awww-daemon")
    hl.exec_cmd("kitty --listen-on unix:/tmp/kitty.sock --single-instance")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("lua /home/carlosm/.config/hypr/lua/services/thumbnails.lua")
end)

hl.exec_cmd("/home/carlosm/.config/scripts/system/refresh-display.sh")
