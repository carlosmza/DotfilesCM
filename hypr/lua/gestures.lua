-- Gestures — DotfilesCM

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "up",          scale = 1.0, action = "fullscreen" })
-- hl.gesture({
--     fingers = 3,
--     direction = "down",
--     dispatcher = true,
--     action = "exec",
--     cmd = "/usr/bin/makoctl dismiss -a",
-- })

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})
