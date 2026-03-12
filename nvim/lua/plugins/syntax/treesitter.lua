-- return {
-- 		enable = false,
--     "nvim-treesitter/nvim-treesitter",
--     dependencies = {"nvim-treesitter/nvim-treesitter-textobjects"},
--     build = ":TSUpdate",
--     event = "VeryLazy",
--     -- main = "nvim-treesitter.configs",
--     opts = {
--         ensure_installed = {"c", "lua", "luadoc", "java", "python", "json", "markdown"},
--         highlight = {
--             enabled = true
--         },
--         ident = {
--             enabled = true
--         },
--         incremental_selection = {
--             enabled = true
--         },
--         textobjects = {
--             select = {
--                 enable = true,
--                 lockahead = true,
--                 keymaps = {
--                     ["af"] = "@function.outer",
--                     ["if"] = "@function.inner",
--                     ["ac"] = "@class.outer",
--                     ["ic"] = "@class.inner",
--                     ["al"] = "@loop.outer",
--                     ["il"] = "@loop.inner"
--                 }
--             }
--         }
--     }
-- }





return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate'
}
