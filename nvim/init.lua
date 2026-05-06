require ("config.lazy")
require ("config.keymaps")
require ("config.options")
vim.g.suda_smart_edit = 1  -- Detecta automáticamente si necesita sudo
local theme = vim.fn.system("jq -r .variant /home/carlosm/.config/system-themes/themes/current.json")

if theme == "dark" then
	vim.cmd("colorscheme noirbuddy")
else
	vim.cmd("colorscheme catppuccin-latte")
end
 -- vim.cmd("Lazy sync")
