return {
  "saghen/blink.cmp",
  dependencies = {
        "neovim/nvim-lspconfig",
        "rafamadriz/friendly-snippets",
        "L3MON4D3/LuaSnip"
  },
  version = '1.*',
  lazy = "VeryLazy",
  opts = {
      signature = { enabled = true },
  },
  completion = {
      ghost_text = { enabled = true },
      documentation = { auto_show = true },
      --menu = { auto_show = false},
  },

  config = function()
    local blink = require("blink.cmp")
    blink.setup({
      keymap = {
        preset = "none",
          ['<CR>'] = { 'select_and_accept', 'fallback' },
          ['<Up>'] = { 'select_prev', 'fallback' },
          ['<Down>'] = { 'select_next', 'fallback' },
          ['<C-k>'] = { 'select_prev', 'fallback' },
          ['<C-j>'] = { 'select_next', 'fallback' },
          ['<Tab>'] = { 'select_next', 'fallback' },
          ['<C-e>'] = { 'show', 'show_documentation', 'hide_documentation' },
          ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
          ['<C-U>'] = { 'scroll_documentation_down', 'fallback' },
          -- show with a list of providers
          ['<C-space>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },
      },
      sources = {
        default = { "lsp", "path", "buffer" },
      },
    })

    -- Integración con LSP
    -- local capabilities = blink.get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities())
    local capabilities = blink.get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities())

    vim.lsp.config.clangd = {
        capabilities = capabilities
    }
    vim.lsp.config.pyright = {
        capabilities = capabilities
    }
    -- local lspconfig = require("lspconfig")
    -- lspconfig.clangd.setup({ capabilities = capabilities })
    -- lspconfig.lua_ls.setup({ capabilities = capabilities })
    -- lspconfig.pyright.setup({ capabilities = capabilities })
  end
}

