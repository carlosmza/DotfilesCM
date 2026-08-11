local kmap = vim.keymap.set
local snacks = require("snacks")

----------- <lsp> -----------
kmap("n", "gdx", ":belowright split | lua vim.lsp.buf.definition()<CR>", {desc='below definition'})
kmap("n", "gdv", ":vsplit | lua vim.lsp.buf.definition()<CR>",{desc='vertical definition'})
kmap("n", "gdt", ":tab split | lua vim.lsp.buf.definition()<CR>",{desc='tab definition'})

kmap("n", "<leader>sl", function()
  snacks.picker.lsp_symbols()
end, { desc = "Search LSP symbols" })

kmap("n", "<leader>sd", function()
  snacks.picker.diagnostics_buffer()
end, { desc = "Search diagnostics buffer" })
----------- </lsp> -----------

----------- <cursor> -----------
-- Center cursor
-- kmap("n","j","jzz",{ noremap = true})
-- kmap("n","k","kzz",{ noremap = true})
-- kmap("n","l","lzz",{ noremap = true})
-- kmap("n","h","hzz",{ noremap = true})
-- kmap('n', "<C-u>", "<C-u>zz")
-- kmap('n', "<C-d>", "<C-d>zz")
-- kmap('n', "<C-f>", "<C-f>zz")
-- kmap('n', "<C-b>", "<C-b>zz")
-- kmap('n', "n", "nzzzv")
-- kmap('n', "N", "Nzzzv")
----------- </cursor> -----------


----------- <toggle> -----------
-- Wrap
kmap("n", "<leader>tu", "<cmd>set wrap!<CR>", { desc = "Toggle wrap"})

-- Spell
kmap("n", "<leader>ts", "<cmd>set nospell!<CR>", { desc = "Toggle spell"})

-- Colorizer
kmap("n", "<leader>tc", "<cmd>ColorizerToggle<CR>", { desc = "Toggle colors"})

snacks.toggle.animate():map("<leader>ta")
snacks.toggle.dim():map("<leader>td")
snacks.toggle.indent():map("<leader>ti")
snacks.toggle.scroll():map("<leader>ts")
snacks.toggle.words():map("<leader>tw")
kmap({ "n", "t" }, "<leader>.", function()
  snacks.terminal.toggle()
end, { desc = "Terminal toggle" })

-- Función inteligente para alternar entre Normal -> Zen -> Zoom -> Cerrar
local function toggle_zen_zoom()
  -- 1. Buscar si ya existe una ventana flotante activa creada por snacks.zen
  local zen_activo = false
  local zoom_activo = false

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    
    -- Snacks etiqueta internamente sus buffers de Zen/Zoom de forma predecible
    if string.match(name, "snacks_zen") then
      zen_activo = true
      break
    elseif string.match(name, "snacks_zoom") then
      zoom_activo = true
      break
    end
  end

  -- 2. Máquina de estados para el Toggle combinado:
  if not zen_activo and not zoom_activo then
    -- Estado 0: Todo normal -> Activar Modo Zen (Centrado)
    snacks.zen.zen()
  elseif zen_activo then
    -- Estado 1: Modo Zen activo -> Cerrar Zen y pasar a Modo Zoom (Maximizado)
    snacks.zen.zen() -- Esto cierra el Zen actual de forma segura
    vim.schedule(function()
      snacks.zen.zoom() -- Abrimos el Zoom en el siguiente ciclo de Neovim
    end)
  elseif zoom_activo then
    -- Estado 2: Modo Zoom activo -> Cerrar todo y regresar al estado Normal
    snacks.zen.zoom() -- Esto cierra el Zoom
  end
end
kmap("n", "<leader>tz", toggle_zen_zoom, { desc = "Toggle zen mode" })
----------- </toggle> -----------

----------- <utilities> -----------
-- Lazy
kmap("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "Lazy home"})

-- Copy all Text
kmap("n", "<leader>Y", "<cmd>%y<CR>", { desc = "Copy all text"})

-- Remove search highlighting
kmap({ 'n', 'v', 'i' }, '<Esc>', function()
    if vim.v.hlsearch == 1 then
        vim.cmd 'nohlsearch | redraw!'
    end
    return '<Esc>'
end, { desc = 'Remove search highlighting', expr = true, silent = true })

-- Move lines
kmap('v', 'K', ":m '<-2<CR>gv=gv")
kmap('v', 'J', ":m '>+1<CR>gv=gv")

-- Go to Normal Mode
kmap("i", "jk", "<Esc>", { silent = true})
kmap("i", "kk", "<Esc>", { silent = true })
kmap("i", "<C-c>", "<Esc>", { silent = true })

-- Indent backward
kmap("n", "<", "<<", { desc = "Indent backward (Normal mode)"})

-- Indent forward
kmap("n", ">", ">>", { desc = "Indent forward(Normal mode)"})

-- Indent backward (Visual Mode)
kmap("v", "<", "<gv", { desc = "Indent backward (Visual mode)"})

-- Indent forward (Visual Mode)
kmap("v", ">", ">gv", { desc = "Indent forward(Visual mode)"})

-- Enter Normal Mode (Terminal Mode)
kmap("t", "<Esc>", "<C-\\><C-n>", { desc = "Enter Normal Mode(Terminal)", silent = true })
----------- </utilities> -----------

----------- <window> -----------
-- Close window
kmap("n", "<leader>q", "<C-w>q", { desc = "Close window"})

-- Go to left window
kmap("n", "<C-h>", "<C-w>h", { desc = "Go to left window"})

-- Go to right window
kmap("n", "<C-l>", "<C-w>l", { desc = "Go to right window"})

-- Go to up window
kmap("n", "<C-k>", "<C-w>k", { desc = "Go to up window"})

-- Go to down window
kmap("n", "<C-j>", "<C-w>j", { desc = "Go to down window"})

-- Go to upper window (Terminal)
kmap("t", "<C-j>", "<C-\\><C-N><C-j>", { desc = "General | Go to upper window(Terminal)", silent = true })

-- Go to lower window (Terminal)
kmap("t", "<C-k>", "<C-\\><C-N><C-k>", { desc = "General | Go to lower window(Terminal)", silent = true })

-- Go to left window (Terminal)
kmap("t", "<C-h>", "<C-\\<C-N><C-h>", { desc = "General | Go to left window(Terminal)", silent = true })

-- Go to right window (Terminal)
kmap("t", "<C-l>", "<C-\\><C-N><C-l>", { desc = "General | Go to right window(Terminal)", silent = true })
----------- </window> -----------

----------- <buffers> -----------
kmap("n", "L", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
kmap("n", "H", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous Buffer" })
kmap("n", "<leader>b1", "<cmd>BufferLineGoToBuffer 1<CR>", { desc = "Go to Buffer [1]" })
kmap("n", "<leader>b2", "<cmd>BufferLineGoToBuffer 2<CR>", { desc = "Go to Buffer [2]" })
kmap("n", "<leader>b3", "<cmd>BufferLineGoToBuffer 3<CR>", { desc = "Go to Buffer [3]" })
kmap("n", "<leader>b4", "<cmd>BufferLineGoToBuffer 4<CR>", { desc = "Go to Buffer [4]" })
kmap("n", "<leader>b5", "<cmd>BufferLineGoToBuffer 5<CR>", { desc = "Go to Buffer [5]" })
kmap("n", "<leader>b6", "<cmd>BufferLineGoToBuffer 6<CR>", { desc = "Go to Buffer [6]" })

-- Save Buffer
kmap("n", "<leader>w", "<cmd>w<CR>", { desc = "Save buffer"})

-- Delete Buffer
kmap("n", "<leader>bd", function()
  snacks.bufdelete.delete()
end, { desc = "Delete buffer" })

require("cybu").setup()
-- kmap("n", "H", "<Plug>(CybuPrev)")
-- kmap("n", "L", "<Plug>(CybuNext)")
kmap("n", "<C-Tab>", "<plug>(CybuLastusedNext)")
kmap("n", "<C-S-Tab>", "<plug>(CybuLastusedPrev)")
----------- </buffers> -----------

----------- <find> -----------
kmap("n", "<leader>fs", function()
  snacks.picker.smart()
end, { desc = "Smart Find files" })

kmap("n", "<leader>fr", function()
  snacks.picker.recent()
end, { desc = "Find recent files" })

kmap("n", "<leader>fk", function()
  snacks.picker.keymaps()
end, { desc = "Find keymaps" })

kmap("n", "<leader>fc", function()
  snacks.picker.colorschemes()
end, { desc = "Find colorschemes" })

kmap("n", "<leader>ff", function()
  snacks.picker.files()
end, { desc = "Find files (CWD)" })
----------- </find> -----------

----------- <search> -----------
kmap("n", "<leader>ss", function()
  snacks.picker.grep()
end, { desc = "Search sentence (CWD)" })

kmap("n", "<leader>sc", function()
  snacks.picker.command_history()
end, { desc = "Search command history" })

kmap({"n", "v"}, "<leader>si", function()
  snacks.picker.icons()
end, { desc = "Search icons" })

kmap("n", "<leader>su", function()
  snacks.picker.undo()
end, { desc = "Search undo history" })

-- /home/carlosm/.config/nvim/lua/config/keymaps.lua

-- Invoca a Grug-Far limitando la búsqueda estrictamente a la ruta del archivo actual
kmap("n", "<leader>sr", function()
  -- 1. Obtener la ruta del archivo actual relativa al proyecto ('.')
  local current_file = vim.fn.expand("%:.")

  -- 2. Guardaguardas: Validar que el buffer sea un archivo real
  if current_file == "" or vim.bo.buftype ~= "" then
    vim.notify("El buffer actual no es un archivo válido", vim.log.levels.WARN)
    return
  end

  -- 3. Abrir Grug-Far pasando 'paths' como un STRING plano
  require('grug-far').open({
    prefills = {
      search = vim.fn.expand("<cword>"), -- Captura la palabra bajo el cursor
      paths = current_file,              -- CORRECCIÓN: String plano, sin llaves {}
    },
  })
end, { desc = "Search and Remplace" })----------- </search> -----------

----------- <yazi> -----------
kmap({"n", "v"}, "<leader>-", "<cmd>Yazi cwd<CR>", { desc = "Open Yazi"})
vim.keymap.set("n", "<leader>_", function()
  local current_file = vim.fn.expand("%:p")
  require("yazi").yazi({}, current_file)
end, { desc = "Open Yazi (relative)" })
----------- </yazi> -----------

----------- <zoxide> -----------
local fzf = require('fzf-lua')
local function zoxide_fzf()
  fzf.fzf_exec("zoxide query -l", {
    actions = {
      ["default"] = function(selected)
        if selected and selected[1] then
          vim.cmd("cd " .. selected[1])
          print("CWD: " .. selected[1])
        end
      end,
    },
    winopts = { title = " Zoxide " }
  })
end
kmap("n", "<leader>z", zoxide_fzf, { desc = "Change CWD" })
----------- </zoxide> -----------

----------- <extra> -----------
-- Desactiva el carácter raro de los audífonos
kmap("i", "", "<nop>", { silent = true})

kmap("n", "<leader>d", function()
  snacks.dashboard.open()
end, { desc = "Open Dashboard" })

kmap("n", "<leader>E", function()
  snacks.explorer.open({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "File explorer (BUFF)" })

kmap("n", "<leader>e", function()
  snacks.explorer.open({ cwd = vim.uv.cwd() })
end, { desc = "File explorer (CWD)" })

kmap("n", "<leader>nh", function()
  snacks.notifier.show_history()
end, { desc = "Notify history" })

kmap("n", "<leader>nd", function()
  snacks.notifier.hide()
end, { desc = "Clear notify" })

kmap("n", "<leader>r", function()
  snacks.rename.rename_file()
end, { desc = "Rename file" })

kmap("n", "<leader>sn", function()
  snacks.scratch()
end, { desc = "Scratch: Open new note" })

kmap("n", "<leader>s-", function()
  snacks.scratch.select()
end, { desc = "Scratch: Select notes" })
----------- </extra> -----------

----------- <copy-paste> -----------
-- Kdeconnect
local function blackhole_operator(key)
    vim.keymap.set("n", key, '"_' .. key, {
        noremap = true,
        silent = true,
    })

    vim.keymap.set("x", key, '"_' .. key, {
        noremap = true,
        silent = true,
    })
end

blackhole_operator("d")
blackhole_operator("D")
blackhole_operator("c")
blackhole_operator("C")

----------- </copy-paste> -----------

----------- <disable> -----------
-- --- KEYMAPS PARA SNACKS.SCOPE (Navegación Inteligente) ---

-- 3. Saltar el cursor directamente al inicio del bloque actual (Inicio de la función/clase)

-- kmap({ "n", "x", "o" }, "{s", function()
--   snacks.scope.jump({ 
--     edge = "top",
--     backwards = true, -- Fuerza la búsqueda sintáctica hacia atrás
--   })
-- end, { desc = "Scope: Top" })
-- 4. Saltar el cursor directamente al final del bloque actual (Cierre de la función/clase)
-- kmap({ "n", "x", "o" }, "}s", function()
--   snacks.scope.jump({
-- 		edge = "bottom",
-- 		backwards = false,
-- 	})
-- end, { desc = "Scope: Bottom block" })
-- Inspeccionar el elemento que está bajo el cursor (útil para árboles de Treesitter o variables de Lua)
-- kmap("n", "<leader>di", function()
--   snacks.debug.inspect()
-- end, { desc = "Depurar: Inspeccionar elemento" })
--
-- -- Mostrar el Backtrace actual (pila de llamadas del editor)
-- kmap("n", "<leader>db", function()
--   snacks.debug.backtrace()
-- end, { desc = "Depurar: Mostrar Backtrace" })
-- -- Copy file path
-- kmap('n', '<leader>yp', ":let @+=expand('%:.')<cr>", { desc = 'Copy relative path' })

-- Increse / Decrease width
-- kmap('n', '<C-<>', "<C-w><", { desc = 'Decrease window width'})
-- kmap('n', '<C->>', "<C-w>>", { desc = 'Increse window width'}) -- No funciona, conflicto con ident backward (Normal mode)
----------- </disable> -----------
