require ("config.lazy")
require ("config.keymaps")
require ("config.options")
vim.g.suda_smart_edit = 1  -- Detecta automáticamente si necesita sudo
local file = "/home/carlosm/a.md"
local fwatch = require('fwatch')
-- fwatch.watch(file, {
-- 	on_event = function()
-- 		local theme = vim.fn.system("jq -r .variant /home/carlosm/.config/system-themes/themes/current.json")
-- 		-- vim.cmd("colorscheme noirbuddy")
--     print('Colorscheme change', 'theme:', theme)
--   end
-- })
vim.o.background = "dark"
-- local theme = vim.fn.system("jq -r .variant /home/carlosm/.config/system-themes/themes/current.json")
--
--  -- vim.cmd("Lazy sync")
		-- if theme == "dark" then
		-- 	vim.cmd("colorscheme noirbuddy")
		-- else
		-- 	vim.cmd("colorscheme catppuccin-latte")
		-- end
