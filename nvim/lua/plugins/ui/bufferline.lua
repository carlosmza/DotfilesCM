return {
  "akinsho/bufferline.nvim",
	lazy = false,
	priority = 900,
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    require("bufferline").setup {
      options = {
        mode = "buffers", -- o "tabs"
        numbers = "ordinal", -- o "ordinal", "buffer_id", "both"
        diagnostics = "nvim_lsp",
        separator_style = "thin", -- "slant", "padded_slant", "thin", etc
        show_close_icon = false,
        always_show_bufferline = true,
        offsets = {
          {
            filetype = "NvimTree",
            text = "Explorer",
            highlight = "Directory",
            separator = true
          }
        },
      }
    }
  end,
}

