-- Decoration — DotfilesCM

local var = require("lua.variables")

hl.config({
    decoration = {
        rounding = var.windowRounding,
        rounding_power = var.windowRoundingPower,
        active_opacity = var.windowActiveOpacity,
        inactive_opacity = var.windowInactiveOpacity,
        shadow = {
            enabled = var.shadowEnabled,
            range = var.shadowRange,
            render_power = var.shadowRenderPower,
            color = var.shadowColor,
            color_inactive = var.shadowInactiveColor,
        },
        blur = {
            enabled = var.blurEnabled,
            size = var.blurSize,
            special = var.blurSpecialWs,
            passes = var.blurPasses,
            new_optimizations = true,
            ignore_opacity = true,
            xray = var.blurXray,
        },
    },
})
