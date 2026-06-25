---@type LazySpec
return {
  "mikavilpas/yazi.nvim",
  version = "*", -- use the latest stable version
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  ---@type YaziConfig | {}
  opts = {
		open_pdf_user_command = 'pdftoppm -png -r 150 %s /tmp/yazi-pdf',
    -- if you want to open yazi instead of netrw, see below for more info
    open_for_directories = false,
		use_ya_for_events_reading = true, -- Utiliza el binario 'ya' auxiliar de Yazi para mitigar bloqueos de eventos
		set_keymaps = false, -- Evita conflictos si manejas tus mapas por separado
    keymaps = {
      show_help = "<f1>",
    },
    -- Esta opción es crucial para que no choque con buffers de imágenes flotantes
    floating_window_scaling_factor = 0.8,
  },
  -- 👇 if you use `open_for_directories=true`, this is recommended
  init = function()
    -- mark netrw as loaded so it's not loaded at all.
    --
    -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
    vim.g.loaded_netrwPlugin = 1
  end,
}
