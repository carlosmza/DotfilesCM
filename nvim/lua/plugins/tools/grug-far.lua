return {
  'MagicDuck/grug-far.nvim',
	cmd = { "GrugFar" }, -- Neovim no sabe nada de grug-far hasta que ejecutas :GrugFar
  -- El plugin pospone sus requires, por lo que es ligero por defecto
  config = function()
    require('grug-far').setup({
      -- 1. GEOMETRÍA GLOBAL PARA VENTANAS FLOTANTES (.open())
      windowCreationArgs = {
        relative = 'editor',
        width = math.floor(vim.o.columns * 0.85),
        height = math.floor(vim.o.lines * 0.80),
        row = math.floor(vim.o.lines * 0.10),
        col = math.floor(vim.o.columns * 0.075),
        border = 'rounded',
      },

      -- 2. COMPORTAMIENTO Y ESTÉTICA DEL BUFFER POR DEFECTO
      transient = true, -- El buffer se destruye al cerrarse
      wrap = false,     -- Evita el truncado visual de líneas de código largas
      icons = {
        enabled = true, -- Iconos de NerdFonts activos
      },

      -- 3. MAPEOS INTERNOS DEL BUFFER
      -- Todos los buffers de Grug-Far heredarán estas teclas locales
      keymaps = {
        replace = { n = '<leader>R' },       -- Aplicar reemplazo masivo
        qflist  = { n = '<leader>q' },       -- Enviar al Quickfix list
        syncLocations = { n = '<leader>s' }, -- Sincronizar ediciones manuales
        close   = { n = 'q' },               -- Cerrar buffer flotante con 'q'
      },
    })
  end
}
