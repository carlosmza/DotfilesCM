-- User-facing variables — DotfilesCM
-- Loaded by other modules via require("lua.variables")

local theme = require("lua.scripts.read_theme")
local palette = theme.palette

local var = {}

-- Apps
var.terminal = "kitty"
var.browser = "brave"
var.fileExplorer = "nautilus"
var.pdfViewer = "okular"
var.menu = "rofi -show drun -theme ~/.config/rofi/layouts/list-apps.rasi"

-- Touchpad
var.touchpadFingers = 3
var.touchpadFingersMore = 4

-- Blur
var.blurEnabled = true
var.blurSpecialWs = true
var.blurSize = 8
var.blurPasses = 2
var.blurXray = false

-- Shadow
var.shadowEnabled = true
var.shadowRange = 2
var.shadowRenderPower = 1
var.shadowColor = "rgba(" .. palette.base00 .. "7F)"
var.shadowInactiveColor = "rgba(" .. palette.base01 .. "7F)"

-- Window
var.windowActiveOpacity = 0.98
var.windowInactiveOpacity = 0.95
var.windowRounding = 10
var.windowRoundingPower = 10
var.windowBorderSize = 3
var.activeWindowBorderColour = "rgba(" .. palette.base0D .. "FF)"
var.inactiveWindowBorderColour = "rgba(" .. palette.base02 .. "7F)"
-- var.windowGapsIn = {10,10,10,10}
var.windowGapsIn = 10
-- var.windowGapsOut = {40, 40, 40, 40}
var.windowGapsOut = 20
-- var.windowGapsOut = {5, 5, 5, 5}

-- Misc
var.volumeStep = 5
var.cursorTheme = "sweet-cursors"
var.cursorSize = 12

-- Keybinds
var.mainMod = "SUPER"

return var
