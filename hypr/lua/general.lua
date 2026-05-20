-- General — DotfilesCM

local var = require("lua.variables")

hl.config({
    general = {
        layout = "dwindle",
        allow_tearing = false,
        gaps_in = var.windowGapsIn,
        gaps_out = var.windowGapsOut,
        border_size = var.windowBorderSize,
        resize_on_border = true,
        col = {
            active_border = var.activeWindowBorderColour,
            inactive_border = var.inactiveWindowBorderColour,
        },
    },
})

hl.config({
    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = true,
    },
})
