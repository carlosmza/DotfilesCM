require("vim._core.ui2").enable({})
require ("config.lazy")
require ("config.keymaps")
require ("config.options")

vim.g.suda_smart_edit = 1  -- Detecta automáticamente si necesita sudo

local colorscheme_file = vim.fn.expand("~/.config/nvim/.colorscheme")

local theme_map = {
-- "Theme name": "colorscheme name"
	ashes    = "noirbuddy",
  ["gruvbox-dark-medium"]  = "gruvbox",
  ["gruvbox-light-soft"]  = "gruvbox",
  ["rose-pine-dawn"]    = "rose-pine-dawn",
  ["tokyo-night-dark"]    = "tokyonight-night",
}

local function aplicar_tema()
  local file = io.open(colorscheme_file, "r")
  if not file then
    vim.notify(".colorscheme no encontrado en " .. colorscheme_file, vim.log.levels.WARN)
    return
  end

  local key = vim.trim(file:read("*a") or "")
  file:close()

  if key == "" then
    vim.notify(".colorscheme está vacío", vim.log.levels.WARN)
    return
  end

  local scheme = theme_map[key:lower()]
  if scheme then
    vim.cmd("colorscheme " .. scheme)
  else
    vim.notify("Tema no mapeado: " .. key, vim.log.levels.WARN)
  end
end

aplicar_tema()
