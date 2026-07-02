return {
  "ghillb/cybu.nvim",
  branch = "main", -- timely updates
  -- branch = "v1.x", -- won't receive breaking changes
  dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" }, -- optional for icon support
  opts = {}, -- automatically calls require("cybu").setup()
	config = function()
		require("cybu").setup({
			display_time = 50
		})
	end,
}
