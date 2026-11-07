-- lua/plugins/mini.lua
return {
  "echasnovski/mini.nvim",
	priority = 900,
  version = false,
  event = "VeryLazy",
  config = function()
    -- Manipulación de envoltorios (paréntesis, comillas)
    require("mini.surround").setup()

    -- Extensión de objetos de texto (funciones, argumentos)
    require("mini.ai").setup()

    -- Autocompletado de parejas
    require("mini.pairs").setup()

    -- Resaltado de colores Hex en archivos de config
    require("mini.hipatterns").setup({
      highlighters = {
        hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
      },
    })

    -- Resaltado automático de la palabra bajo el cursor
    -- require("mini.cursorword").setup()
		require('mini.tabline').setup()
  end,
}

