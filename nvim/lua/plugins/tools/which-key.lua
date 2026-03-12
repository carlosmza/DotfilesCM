return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    enabled = true,
    opts = {
      -- plugins = {
      --   spelling = {
      --     enabled = true,
      --   },
      -- },
      icons = {
          breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
          separator = "➜", -- symbol used between a key and it's label
          group = "", -- symbol prepended to a group
      },
      preset = "modern",
      win = {
          border = vim.g.border_enabled and "rounded" or "none",
          no_overlap = false,
      },
      delay = function()
        return 0
      end,
    },
    config = function (_,opts)
	    require("which-key").setup(opts)
	    require("which-key").add {
            {
                { "<leader>f", group = "find", icon = "󰮗"},
                { "<leader>b", group = "buffers", icon = ""},
            },

    }
    end,
}
