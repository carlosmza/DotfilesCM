return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    require("bufferline").setup {
      options = {
        mode = "buffers", -- o "tabs"
        numbers = "buffer_id", -- o "ordinal", "buffer_id", "both"
        diagnostics = "nvim_lsp",
        separator_style = "padded_slant", -- "slant", "padded_slant", "thin", etc
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

