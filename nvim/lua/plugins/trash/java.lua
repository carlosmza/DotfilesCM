-- Dentro de tu archivo java.lua, o en plugins/language/java.lua, etc.
return {
  {
    "nvim-java/nvim-java",
    lazy = true,  -- cargar al inicio para que jdtls se configure
    enabled = false,
    dependencies = {},
    config = function()
      -- Primero configura java con nvim-java
      require("java").setup({
        -- Aquí puedes pasar opciones específicas si deseas
        -- Por ejemplo paths extras, configuración de proyecto, etc.
      })

      -- Ahora configurar jdtls vía lspconfig, asegurándote de usar Blink capabilities
      -- local lspconfig = require("lspconfig")
      local capabilities = require("blink.cmp").get_lsp_capabilities(
        vim.lsp.protocol.make_client_capabilities()
      )

      -- Opcionalmente setear root_dir, vimopts, etc.
      vim.lsp.config.jdtls.setup({
        capabilities = capabilities,
        -- puede que nvim-java ya haga buena parte de esta config
        -- si necesitas ajustes personalizados, los pones aquí
      })
    end,
    ft = {"java"},  -- solo cargar para archivos Java
  }
}

