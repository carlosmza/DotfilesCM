return
-- Lua
{
  "folke/persistence.nvim",
  event = "BufReadPre", -- this will only start session saving when an actual file was opened
	enabled = false,
  opts = {
    dir = vim.fn.stdpath("state") .. "/sessions/", -- ruta por defecto
    options = { "buffers", "curdir", "tabpages", "winsize" },
  },
  config = function(_, opts)
    local persistence = require("persistence")
    persistence.setup(opts)

    -- 🔧 Desactiva el autoload y autoguardado
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        -- No cargar automáticamente sesiones
      end,
    })

    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        -- No guardar automáticamente sesiones
      end,
    })
  end,
}
