return {
  -- Lualine
  {"nvim-lualine/lualine.nvim",
--  dependencies = {"nvim-tree/nvim-web-icons"},
	lazy = false,
	priority = 1000,
    config = function()
        require("lualine").setup{
		options = {
		    icons_enabled = true,
		    theme = 'auto',

		    component_separators = { left = '', right = ''},
		    section_separators = { left = '', right = ''},
		    disabled_filetypes = {
		      statusline = {},
		      winbar = {},
		    },
		    ignore_focus = {},
		    always_divide_middle = true,
		    globalstatus = false,
		    refresh = {
		      statusline = 1000,
		      tabline = 1000,
		      winbar = 1000,
		    }
		  },
		  sections = {
				-- lualine_a = { { 'mode', separator = { left = ' ' }, right_padding = 2 } },
				lualine_a = {'mode'},
		    lualine_b = {'branch', 'diff', 'diagnostics'},
		    lualine_c = {'filename'},
		    lualine_x = {},
		    lualine_y = {'filetype'},
				lualine_z = { { 'location', separator = { right = ' ' }, left_padding = 2 } },

		  },
		  inactive_sections = {
		    lualine_a = {},
		    lualine_b = {},
		    lualine_c = {'filename'},
		    lualine_x = {'location'},
		    lualine_y = {},
		    lualine_z = {}
		  },
		  tabline = {
			--lualine_a = {'tabs'},
		  },
		  winbar = {},
		  inactive_winbar = {},
		  extensions = {}
	} -- Aquí se activa el plugin
    end,
    },
}
