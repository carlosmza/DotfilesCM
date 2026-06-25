return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    enabled = true,
    opts = {
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
                { "<leader>s", group = "search", icon = "󰬴"},
                { "<leader>b", group = "buffers", icon = ""},
                { "<leader>t", group = "toggles", icon = ""},
								{ "<leader>n", group = "notifications", icon ="󰍩"},
                { "<leader>Y", icon ="󰆏"},
								{ "<leader>d", icon ="󰨝"},
                { "<leader>z", icon =""},
                { "<leader>-", icon =""},
                { "<leader>e", icon =""},
                { "<leader>l", icon =""},
                { "<leader>h", icon =""},
                { "<leader>r", icon ="󰑕"},
                { "<leader>w", icon =""},
            },

    }
    end,
}
