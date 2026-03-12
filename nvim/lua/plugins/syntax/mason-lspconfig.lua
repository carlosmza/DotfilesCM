return {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {},
    completion = { documentation = { auto_show = true } },
    config = function ()
             require("mason-lspconfig").setup({
             ensure_installed = {},
             automatic_installation = true,
        })

        -- local lspconfig = require("lspconfig")
        local capabilities = require("blink.cmp").get_lsp_capabilities(
          vim.lsp.protocol.make_client_capabilities()
        )
        vim.lsp.config.clangd = {
            capabilities = capabilities
        }
        vim.lsp.config.pyright = {
            capabilities = capabilities
        }
        
        -- lspconfig.clangd.setup({ capabilities = capabilities })
        -- lspconfig.lua_ls.setup({ capabilities = capabilities })
        -- lspconfig.pyright.setup({ capabilities = capabilities })
        --lspconfig.jdtls.setup({ capabilities = capabilities })
    end
}
