return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    animate = {
      enabled = true,
      fps = 120,          -- Tasa de refresco (60 o 120 van perfectos para monitores modernos)
      duration = 20,      -- Duración en milisegundos por cada paso (step) de la animación
      easing = "outQuad", -- Curva de interpolación ("linear", "outQuad", "inQuad", "outCubic", etc.)
    },
    bigfile = {
      enabled = true,
      notify = true,               -- show notification when big file detected
      size = 2 * 1024 * 1024,      -- 2MB
      features = {
        indent = false,            -- Desactiva guías de indentación visuales
        lsp = false,               -- Desactiva servidores LSP para este buffer
        matchparen = false,        -- Desactiva el resaltado de pares de llaves/paréntesis
        syntax = false,            -- Desactiva el motor de sintaxis pesado clásico de Vim
        treesitter = false,        -- Desactiva el parser de Treesitter
        undo = false,              -- No genera archivos de undo persistentes
      },
    },
    bufdelete = { enabled = true }, -- Habilita el módulo de borrado inteligente
    dashboard = {
      enabled = true,
			cache = false,
      sections = {
				{
          text = [[


          █ █ █ █▀▀ █   █▀▀ █▀█ █▀▄▀█ █▀▀
          ▀▄▀▄▀ █▀▀ █   █   █▄█ █ ▀ █ █▀▀
           ▀ ▀  ▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀   ▀ ▀▀▀

              ▄▀▀ █▀█ █▀▄ █   ▄▀▀▄ ▄▀▀
              ▀▄▄ █▀█ █▀▄ █▄▄ ▀▄▄▀ ▄██
          ]],
          hl = "Title", -- Cambia el color de tu ASCII (ej: Keyword, Title, Function, String)
          padding = 1,
        },
        { section = "recent_files", icon = " ", title = "Recent files", indent = 2, padding = 1 },
        { section = "projects", icon = " ", title = "Projects", indent = 2, padding = 1 },
        { section = "startup" },
      },
    },
    debug = { enabled = false },
    dim = { enabled = true },
    explorer = { enabled = true },
    image = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    picker = { enabled = true },
    quickfile = { enabled = true },
    rename = { enabled = true },
    scope = { enabled = true },
    scratch = { enabled = true },
    scroll = {
      enabled = true,
      animate = {
        duration = { step = 15, total = 250 }, -- Duración en milisegundos
        easing = "linear",                     -- Tipo de curva de animación (ej. "linear", "quadratic", "cubic")
      },
      spamming = 10,                           -- Detiene la animación si envías demasiados comandos seguidos para no saturar
    },
    statuscolumn = {
      enabled = true,
      left = { "mark", "sign" },  -- Qué mostrar a la extrema izquierda (marcas y signos de error/git)
      right = { "fold", "git" },  -- Qué mostrar justo antes del inicio del texto
      folds = {
        open = true,              -- Mostrar indicador si el bloque está abierto
        git_hl = true,            -- Colorear los signos de pliegue según el estado de Git
      },
    },
    styles = {
      terminal = {
        position = "float", -- Fuerza a que sea flotante en lugar de un split inferior
        border = "rounded", -- Bordes redondeados estéticos
        backdrop = 90,      -- Atenúa el fondo del editor detrás de la terminal (0-100)
        width = 0.5,        -- Ancho de la terminal flotante
        height = 0.5,       -- Alto de la terminal flotante
        row = 0.4,          -- Desplazamiento vertical
        col = 0.25,         -- Desplazamiento horizontal
      },
    },
    terminal = { enabled = true },
    toggle = {
      enabled = true,
      notify = true, -- show a notification when toggling
    },
    -- CORRECCIÓN: Estos 4 módulos ahora están correctamente anidados dentro de 'opts'
    util = { enabled = true },
    win = { enabled = true },
    words = { enabled = true },
    zen = { enabled = true },
  }, -- Fin estricto de 'opts'
}
