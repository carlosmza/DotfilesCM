-- Hyprland Lua config — DotfilesCM
-- Entry point: requires modular Lua files under lua/

-- =============================================================================
-- Monitors
-- =============================================================================
hl.monitor({ output = "eDP-1",    mode = "1920x1080@60",  position = "0x0",    scale = "1" })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@100", position = "1920x0", scale = "1" })

hl.workspace_rule({ workspace = "1", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1" })

-- =============================================================================
-- Modules
-- =============================================================================
require("lua.variables")
require("lua.env")
require("lua.general")
require("lua.decoration")
require("lua.input")
require("lua.animations")
require("lua.rules")
require("lua.gestures")
require("lua.execs")
require("lua.keybinds")
