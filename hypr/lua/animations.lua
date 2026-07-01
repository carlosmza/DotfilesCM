-- Animations — DotfilesCM

hl.config({
    animations = {
        enabled = true,
    },
})
-- hl.curve( NAME, { type = "bezier", points = { {X0, Y0}, {X1, Y1} } })
-- hl.curve( NAME, { type = "spring", mass = MASS, stiffness = STIFF, dampening = DAMP })
--  ↳ workspaces - styles: slide, slidevert, fade, slidefade, slidefadevert

hl.curve("preset_1",           { type = "bezier", points = { {0.84, -0.55},   {1, 2} } })
hl.curve("preset_2",           { type = "bezier", points = { {0.84, -0.55},   {0.77, 1.1} } })
hl.curve("preset_3",           { type = "bezier", points = { {0, 1.1},   {1, -0.5} } })
hl.curve("preset_4",           { type = "bezier", points = { {0.2, 0},   {0, 1} } })
hl.curve("preset_5",           { type = "bezier", points = { {0.5, 0.02},   {0.6, 0.47} } })
-- hl.curve( "rubber", { type = "spring", mass = 1, stiffness = 80, dampening = 10 } )

-- hl.animation({ leaf = STRING, enabled = BOOLEAN, speed = FLOAT, curve = STRING[, style = STRING] })
hl.animation({ leaf = "windowsIn",         enabled = true, speed = 4,  bezier = "preset_5" , style = "popin"})
hl.animation({ leaf = "windowsOut",        enabled = true, speed = 4,  bezier = "preset_2" , style = "slide"})
hl.animation({ leaf = "windowsMove",       enabled = true, speed = 6,  bezier = "preset_4" })
hl.animation({ leaf = "layersIn",          enabled = true, speed = 5,  bezier = "preset_3",  style = "fade" })
hl.animation({ leaf = "layersOut",         enabled = true, speed = 6,  bezier = "preset_3",  style = "fade" })
hl.animation({ leaf = "fadeLayers",        enabled = true, speed = 5,  bezier = "preset_4" })
hl.animation({ leaf = "fade",              enabled = true, speed = 6,  bezier = "preset_4" })
hl.animation({ leaf = "fadeDim",           enabled = true, speed = 6,  bezier = "preset_5" })
hl.animation({ leaf = "border",            enabled = true, speed = 3,  bezier = "preset_5" })
hl.animation({ leaf = "workspaces",        enabled = true, speed = 2.5,  bezier = "preset_1", style = "fade" })
hl.animation({ leaf = "specialWorkspace",  enabled = true, speed = 2.5,  bezier = "preset_1", style = "fade" })
