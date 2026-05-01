return
{
  "hkupty/iron.nvim",
	enabled = false,
  config = function()
    local iron = require("iron.core")
    iron.setup {
      config = {
        repl_definition = {
          python = {
            command = { "python3" }
          },
        },
        repl_open_cmd = "vertical botright 80 split",
      },
      keymaps = {
        send_motion = "<space>im",
        visual_send = "<space>iv",
        send_file = "<space>if",
      },
    }
  end,
}

