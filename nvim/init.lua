require ("config.lazy")
require ("config.keymaps")
require ("config.options")
vim.g.suda_smart_edit = 1  -- Detecta automáticamente si necesita sudo

local theme_file = vim.fn.expand("~/.config/system-themes/current")

local function reload_ui()
  -- lualine
  require("lualine").setup()

  -- which-key
  require("which-key").setup()

  -- fzf-lua (opcional)
  require("fzf-lua").setup()

  -- refrescar highlights
  vim.cmd("doautocmd ColorScheme")
end

local function apply_theme()
  local file = io.open(theme_file, "r")
  if not file then return end

  local theme = file:read("*l")
  file:close()

  if theme == "Dark" then
    vim.cmd("colorscheme noirbuddy")
  else
    vim.cmd("colorscheme catppuccin-latte")
  end
	-- vim.cmd("Lazy sync")
	reload_ui()
end

-- aplicar al inicio
apply_theme()

-- watcher 🔥
vim.loop.new_fs_event():start(theme_file, {}, vim.schedule_wrap(function()
  apply_theme()
end))
