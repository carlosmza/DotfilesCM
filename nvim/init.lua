require("vim._core.ui2").enable({})
require ("config.lazy")
require ("config.keymaps")
require ("config.options")
vim.g.suda_smart_edit = 1  -- Detecta automáticamente si necesita sudo
-- Colores predefinidos
local light_scheme = "rose-pine-dawn"   -- cámbialo a tu gusto
local dark_scheme = "gruvbox"  -- cámbialo a tu gusto
local json_path = "/home/carlosm/.config/system-themes/themes/current.json"

-- Función que lee el valor "variant" con jq y aplica el tema
local function aplicar_tema()
  local resultado = vim.fn.system(string.format("jq -r .variant %s", json_path))
  local variant = vim.trim(resultado)  -- quitar salto de línea final

  if variant == "light" then
    vim.cmd("colorscheme " .. light_scheme)
  elseif variant == "dark" then
    vim.cmd("colorscheme " .. dark_scheme)
  else
    vim.notify("Valor inesperado de 'variant': " .. variant, vim.log.levels.WARN)
  end
end

-- Activar el watcher con fwatch
local fwatch = require("fwatch")
fwatch.watch(json_path, {
  on_event = function()
    -- vim.schedule asegura que la llamada a system y al cmd no choquen con el event loop
    vim.schedule(aplicar_tema)
  end,
  on_error = function(err)
    vim.notify("Error en fwatch: " .. err, vim.log.levels.ERROR)
  end,
})

-- Aplicar el tema ya que inicialmente el archivo puede tener un valor
aplicar_tema()
