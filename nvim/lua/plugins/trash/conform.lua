return {
    'stevearc/conform.nvim',
  opts = {},
  enable = false,
  config = function ()
require("conform").setup({
  formatters_by_ft = {
      c = {"clang_format"},
    lua = { "stylua" },
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },
  },
})
  end
}
