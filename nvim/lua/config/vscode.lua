-- ============================================================================
--  config.vscode — Neovim embebido en VS Code (vscode-neovim)
-- ============================================================================
--  Se carga desde init.lua cuando vim.g.vscode está definido, y devuelve el
--  control ANTES de lazy.nvim, así que aquí no hay snacks/blink/lualine.
--  Todo lo que en Neovim hacía un plugin de UI/UI-picker se resuelve llamando
--  a comandos de VS Code vía require("vscode").action()/call().
-- ============================================================================

if not vim.g.vscode then
  return
end

local vscode = require("vscode")
local kmap = vim.keymap.set

----------- <helpers> -----------
-- Ejecuta un comando de VS Code desde un keymap
local function act(name, args)
  return function()
    vscode.action(name, args and { args = args } or nil)
  end
end

-- Alterna una setting de VS Code entre dos valores
local function toggle_setting(name, on, off)
  return function()
    local cur = vscode.get_config(name)
    vscode.update_config(name, cur == on and off or on, "global")
  end
end
----------- </helpers> -----------

----------- <options> -----------
-- (options.lua) — replicado lo que tiene sentido con Neovim embebido.
-- Números relativos, wrap, indentación visual, etc. los controla VS Code
-- desde settings.json (editor.lineNumbers, editor.wordWrap, [lang].tabSize…).
vim.g.mapleader = " "
vim.opt.clipboard = "unnamedplus"
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 50
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.scrolloff = 0
vim.opt.smartindent = true

-- Portapapeles a través de la API de VS Code (fiable dentro del flatpak)
vim.g.clipboard = vim.g.vscode_clipboard
vim.notify = vscode.notify
----------- </options> -----------

----------- <blackhole> -----------
-- Como en Neovim: d/D/c/C no tocan el portapapeles del sistema
local function blackhole(k)
  kmap({ "n", "x" }, k, '"_' .. k, { silent = true })
end
blackhole("d")
blackhole("D")
blackhole("c")
blackhole("C")

-- Excepción: la selección sí va al portapapeles con <leader>d
kmap("x", "<leader>d", '"+d', { desc = "Delete selection to clipboard", silent = true })
----------- </blackhole> -----------

----------- <editing> -----------
-- Mover líneas (visual)
kmap("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
kmap("v", "K", ":m '<-2<CR>gv=gv", { silent = true })

-- Indentar
kmap("n", "<", "<<", { desc = "Indent backward" })
kmap("n", ">", ">>", { desc = "Indent forward" })
kmap("v", "<", "<gv", { desc = "Indent backward (visual)" })
kmap("v", ">", ">gv", { desc = "Indent forward (visual)" })

-- Quitar resaltado de búsqueda con Esc
kmap({ "n", "v", "i" }, "<Esc>", function()
  if vim.v.hlsearch == 1 then
    vim.cmd("nohlsearch | redraw!")
  end
  return "<Esc>"
end, { desc = "Remove search highlighting", expr = true, silent = true })

-- Salir de Insert (jk / kk los gestiona vscode-neovim.compositeKeys)
kmap("i", "<C-c>", "<Esc>", { silent = true })
----------- </editing> -----------

----------- <lsp> -----------
kmap("n", "gdx", act("runCommands", { commands = { "workbench.action.splitEditorDown", "editor.action.revealDefinition" } }),
  { desc = "Definition below" })
kmap("n", "gdv", act("editor.action.revealDefinitionAside"), { desc = "Definition on vertical split" })
kmap("n", "gdt", act("editor.action.revealDefinition"), { desc = "Definition in new tab" })

kmap("n", "<leader>sl", act("workbench.action.gotoSymbol"), { desc = "Search LSP symbols" })
kmap("n", "<leader>sd", act("workbench.actions.view.problems"), { desc = "Search diagnostics" })

-- gd / gD / gh / gO / K / C-] ya vienen de serie en vscode-neovim
kmap("n", "grn", act("editor.action.rename"), { desc = "Rename symbol" })
kmap({ "n", "x" }, "gra", act("editor.action.quickFix"), { desc = "Code action" })
kmap("n", "grr", act("editor.action.referenceSearch.trigger"), { desc = "References" })
kmap("n", "[d", act("editor.action.marker.prev"), { desc = "Previous diagnostic" })
kmap("n", "]d", act("editor.action.marker.next"), { desc = "Next diagnostic" })
----------- </lsp> -----------

----------- <find> -----------
kmap("n", "<leader>fs", act("workbench.action.quickOpen"), { desc = "Smart find files" })
kmap("n", "<leader>ff", act("workbench.action.quickOpen"), { desc = "Find files (cwd)" })
kmap("n", "<leader>fr", act("workbench.action.openRecent"), { desc = "Find recent files" })
kmap("n", "<leader>fk", act("workbench.action.openGlobalKeybindings"), { desc = "Find keymaps" })
kmap("n", "<leader>fc", act("workbench.action.selectTheme"), { desc = "Find colorschemes" })

kmap("n", "<leader>ss", act("workbench.action.findInFiles"), { desc = "Live grep" })
kmap("n", "<leader>sr", function()
  -- Equivalente a grug-far sobre la palabra bajo el cursor
  vscode.action("workbench.action.findInFiles", {
    args = {
      query = vim.fn.expand("<cword>"),
      replace = "",
      triggerSearch = false,
    },
  })
end, { desc = "Search and replace" })
kmap("n", "<leader>sc", act("workbench.action.quickOpen", { ">" }), { desc = "Command palette (historial)" })
kmap("n", "<leader>sn", act("workbench.action.files.newUntitledFile"), { desc = "Scratch: new note" })
----------- </find> -----------

----------- <explorer> -----------
kmap("n", "<leader>e", act("workbench.view.explorer"), { desc = "Explorer (cwd)" })
kmap("n", "<leader>E", act("workbench.files.action.focusFilesExplorer"), { desc = "Explorer (current file dir)" })
kmap({ "n", "v" }, "<leader>-", act("workbench.view.explorer"), { desc = "Explorer" })
kmap("n", "<leader>r", act("runCommands", { commands = { "workbench.files.action.focusFilesExplorer", "renameFile" } }),
  { desc = "Rename file" })
----------- </explorer> -----------

----------- <buffers> -----------
kmap("n", "<leader>w", "<cmd>w<CR>", { desc = "Save buffer" })
kmap("n", "<leader>q", "<cmd>q<CR>", { desc = "Close editor" })
kmap("n", "<leader>bd", act("workbench.action.closeActiveEditor"), { desc = "Delete buffer" })
kmap("n", "L", act("workbench.action.nextEditor"), { desc = "Next buffer" })
kmap("n", "H", act("workbench.action.previousEditor"), { desc = "Previous buffer" })
kmap("n", "<leader>Y", act("editor.action.clipboardCopyAction"), { desc = "Copy all text" })

-- <C-Tab> / <C-S-Tab> (MRU de buffers) ya es el comportamiento nativo de VS Code
-- y <leader>b1..b6 quedan cubiertos por <C-Tab> / Quick Open.
----------- </buffers> -----------

----------- <toggle> -----------
kmap("n", "<leader>tu", toggle_setting("editor.wordWrap", "on", "off"), { desc = "Toggle wrap" })
kmap("n", "<leader>ts", toggle_setting("editor.smoothScrolling", true, false), { desc = "Toggle smooth scroll" })
kmap("n", "<leader>tc", toggle_setting("editor.colorDecorators", true, false), { desc = "Toggle colorizer" })
kmap("n", "<leader>ti", toggle_setting("editor.guides.indentation", true, false), { desc = "Toggle indent guides" })
kmap("n", "<leader>tw", toggle_setting("editor.occurrencesHighlight", "singleFile", "off"),
  { desc = "Toggle word highlight" })
-- Sin equivalente directo en VS Code: <leader>ta (animate) y <leader>td (dim).

kmap("n", "<leader>tz", act("workbench.action.toggleZenMode"), { desc = "Toggle zen mode" })
kmap({ "n", "t" }, "<leader>.", act("workbench.action.terminal.toggleTerminal"), { desc = "Terminal toggle" })
----------- </toggle> -----------

----------- <notifications> -----------
kmap("n", "<leader>nh", act("notifications.showList"), { desc = "Notification history" })
kmap("n", "<leader>nd", act("notifications.clearAll"), { desc = "Clear notifications" })
----------- </notifications> -----------

----------- <utilities> -----------
kmap("n", "<leader>L", act("workbench.view.extensions"), { desc = "Extensions (Lazy)" })
-- Sin equivalente: <leader>z (zoxide), <leader>si (iconos), <leader>s- (scratch
-- picker), <leader>su (undo history), <leader>_ (yazi relativo al archivo).
----------- </utilities> -----------
