return {
  "saghen/blink.cmp",
  dependencies = {
        "rafamadriz/friendly-snippets",
  },
  version = '1.*',
  lazy = "VeryLazy",
  opts = {
      signature = { enabled = true },
			cmd = { enabled = true},
			completion = {
				ghost_text = { enabled = true },
				documentation = { auto_show = true },
				menu = { auto_show = false, border = "single"},
		}
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
          ['<S-Tab>'] = { 'select_prev', 'fallback' },
          ['<C-e>'] = { 'show', 'show_documentation', 'hide_documentation' },
          ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
          ['<C-U>'] = { 'scroll_documentation_down', 'fallback' },
          -- show with a list of providers
          ['<C-space>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },
      },
      sources = {
        default = { "lsp", "path", "buffer" },
      },
			fuzzy = {
				implementation = "prefer_rust_with_warning"	
			}
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
    vim.lsp.config.qmlls = {
        capabilities = capabilities
    }
		vim.lsp.config.emmylua_ls = {
				capabilities = capabilities
		}
  end
}

