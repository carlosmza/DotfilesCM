require ("config.lazy")
require ("config.keymaps")
require ("config.options")
vim.g.suda_smart_edit = 1  -- Detecta automáticamente si necesita sudo


local theme = os.getenv("THEME_COLOR") or "dark"

if theme == "dark" then
  vim.cmd("colorscheme noirbuddy")
else
  vim.cmd("colorscheme catppuccin-latte")
	-- vim.o.background = "light" -- or "light" for light mode
	-- vim.cmd([[colorscheme gruvbox]])
	--  vim.cmd("colorscheme catppuccin-latte")
end

