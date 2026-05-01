local kmap = vim.keymap.set
kmap("n", "gdx", ":belowright split | lua vim.lsp.buf.definition()<CR>", {desc='below definition'})
kmap("n", "gdv", ":vsplit | lua vim.lsp.buf.definition()<CR>",{desc='vertical definition'})
kmap("n", "gdt", ":tab split | lua vim.lsp.buf.definition()<CR>",{desc='tab definition'})

-- Centrar el cursor
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
--
-- Move lines
kmap('v', 'K', ":m '<-2<CR>gv=gv")
kmap('v', 'J', ":m '>+1<CR>gv=gv")

-- Copy file path
kmap('n', '<leader>yp', ":let @+=expand('%:.')<cr>", { desc = 'Copy relative path' })

-- Increse / Decrease width
kmap('n', '<C-<>', "<C-w><", { desc = 'Decrease window width'})
kmap('n', '<C->>', "<C-w>>", { desc = 'Increse window width'}) -- No funciona, conflicto con ident backward (Normal mode)
-- Go to Normal Mode
kmap("i", "jk", "<Esc>", { silent = true})
kmap("i", "kk", "<Esc>", { silent = true })
kmap("i", "<C-c>", "<Esc>", { silent = true })
-- Desactiva el carácter raro de los audífonos
kmap("i", "", "<nop>", { silent = true})

-- Toggle Wrap
kmap("n", "<leader>u", "<cmd>set wrap!<CR>", { desc = "Wrap"})
--
-- Spell
kmap("n", "<leader>S", "<cmd>set nospell!<CR>", { desc = "Spell"})

-- Save Buffer
kmap("n", "<leader>w", "<cmd>w<CR>", { desc = "Save"})

-- Quit Buffer
kmap("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit"})

-- Save Buffer and Exit
kmap("n", "<leader>W", "<cmd>wq<CR>", { desc = "Save"})

-- Quit Buffer and Exit
kmap("n", "<leader>Q", "<cmd>q!<CR>", { desc = "Quit"})

-- Yank all Text
kmap("n", "<leader>Y", "<cmd>%y<CR>", { desc = "Yank All Text"})


-- Go to left window
kmap("n", "<C-h>", "<C-w>h", { desc = "Go to left window"})

-- Go to right window
kmap("n", "<C-l>", "<C-w>l", { desc = "Go to right window"})

-- Go to up window
kmap("n", "<C-k>", "<C-w>k", { desc = "Go to up window"})

-- Go to down window
kmap("n", "<C-j>", "<C-w>j", { desc = "Go to down window"})
-- Indent backward
-- kmap("n", "<", "<<", { desc = "Indent backward (Normal mode)"})

-- Indent forward
kmap("n", ">", ">>", { desc = "Indent forward(Normal mode)"})

-- Indent backward (Visual Mode)
kmap("v", "<", "<gv", { desc = "Indent backward (Visual mode)"})

-- Indent forward (Visual Mode)
kmap("v", ">", ">gv", { desc = "Indent forward(Visual mode)"})

-- Enter Normal Mode (Terminal Mode)
kmap("t", "<Esc>", "<C-\\><C-n>", { desc = "Enter Normal Mode(Terminal)", silent = true })

-- Go to upper window (Terminal)
kmap("t", "<C-j>", "<C-\\><C-N><C-j>", { desc = "General | Go to upper window(Terminal)", silent = true })

-- Go to lower window (Terminal)
kmap("t", "<C-k>", "<C-\\><C-N><C-k>", { desc = "General | Go to lower window(Terminal)", silent = true })

-- Go to left window (Terminal)
kmap("t", "<C-h>", "<C-\\<C-N><C-h>", { desc = "General | Go to left window(Terminal)", silent = true })

-- Go to right window (Terminal)
kmap("t", "<C-l>", "<C-\\><C-N><C-l>", { desc = "General | Go to right window(Terminal)", silent = true })

-- Save current session
kmap("n", "<leader>Qs", function()
  require("persistence").save()
  print("Sesión guardada manualmente ✅")
end, { desc = "Guardar sesión manualmente" })

-- Session list
kmap("n", "<leader>QL", function()
  require("persistence").load()
end, { desc = "Listar sesiones guardadas" })

-- Load last session
kmap("n", "<leader>Qls", function()
  require("persistence").load({ last = true })
end, { desc = "Cargar última sesión" })

-- Delete all sessions
kmap("n", "<leader>Qd", function()
  vim.fn.delete(vim.fn.stdpath("state") .. "/sessions", "rf")
  vim.fn.mkdir(vim.fn.stdpath("state") .. "/sessions", "p")
  print("Sesiones eliminadas 🧹")
end, { desc = "Eliminar todas las sesiones" })

-- Buffers
kmap("n", "<leader>l", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
kmap("n", "<leader>h", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous Buffer" })
kmap("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close Buffer" })
kmap("n", "<leader>b1", "<cmd>BufferLineGoToBuffer 1<CR>", { desc = "Go to Buffer [1]" })
kmap("n", "<leader>b2", "<cmd>BufferLineGoToBuffer 2<CR>", { desc = "Go to Buffer [2]" })
kmap("n", "<leader>b3", "<cmd>BufferLineGoToBuffer 3<CR>", { desc = "Go to Buffer [3]" })
kmap("n", "<leader>b4", "<cmd>BufferLineGoToBuffer 4<CR>", { desc = "Go to Buffer [4]" })

-- Fzf
kmap("n", "<leader>ff0", "<cmd>FzfLua files <CR>", { desc = "Open Files (cwd)" })
kmap("n", "<leader>ff1", "<cmd>FzfLua files cwd=/ <CR>", { desc = "Open Files (root)" })
kmap("n", "<leader>fb", "<cmd>FzfLua buffers <CR>", { desc = "Open Buffers" })
kmap("n", "<leader>fr", "<cmd>FzfLua oldfiles <CR>", { desc = "Recent Files" })
kmap("n", "<leader>fs0", "<cmd>FzfLua lgrep_curbuf <CR>", { desc = "Find Sentence in Buffer" })
kmap("n", "<leader>fs1", "<cmd>FzfLua live_grep <CR>", { desc = "Find Sentence (CWD)" })
kmap("n", "<leader>fs2", "<cmd>FzfLua live_grep cwd=/ <CR>", { desc = "Find Sentence (Root)" })

-- Lazy
kmap("n", "<leader>pc", "<cmd>Lazy clean<CR>", { desc = "Lazy | Clean", silent = true })
kmap("n", "<leader>pC", "<cmd>Lazy check<CR>", { desc = "Lazy | Check", silent = true })
kmap("n", "<leader>pd", "<cmd>Lazy debug<CR>", { desc = "Lazy | Debug", silent = true })
kmap("n", "<leader>pi", "<cmd>Lazy install<CR>", { desc = "Lazy | Install", silent = true })
kmap("n", "<leader>ps", "<cmd>Lazy sync<CR>", { desc = "Lazy | Sync", silent = true })
kmap("n", "<leader>pl", "<cmd>Lazy log<CR>", { desc = "Lazy | Log", silent = true })
kmap("n", "<leader>ph", "<cmd>Lazy home<CR>", { desc = "Lazy | Home", silent = true })
kmap("n", "<leader>pH", "<cmd>Lazy help<CR>", { desc = "Lazy | Help", silent = true })
kmap("n", "<leader>pp", "<cmd>Lazy profile<CR>", { desc = "Lazy | Profile", silent = true })
kmap("n", "<leader>pu", "<cmd>Lazy update<CR>", { desc = "Lazy | Update", silent = true })

-- Yazi
-- kmap("n", "<leader>y", "<cmd>Yazi cwd <CR>", { desc = "Open the File Manager (cwd) "})
-- Oil
--vim.keymap.set("n", "-", ":Oil<CR>", { desc = "Open parent directory" })
--vim.keymap.set( "n", "<leader>m", ":Oil --float<CR>", { desc = "Open Oil (floating)" })

-- Fyler
-- kmap("n", "<leader>-", "<cmd>Fyler<CR>", { desc = "Open the File Manager (cwd) "})
kmap("n", "<leader>e", "<cmd>Fyler kind=split_left_most<CR>", { desc = "Open Fyler left"})
kmap("n", "<leader>E", "<cmd>Fyler kind=split_left<CR>", { desc = "Fyler left (relative)"})

-- Remove search highlighting
vim.keymap.set({ 'n', 'v', 'i' }, '<Esc>', function()
    if vim.v.hlsearch == 1 then
        vim.cmd 'nohlsearch | redraw!'
    end
    return '<Esc>'
end, { desc = 'Remove search highlighting', expr = true, silent = true })

-- Colorizer
kmap("n", "<leader>c", "<cmd>ColorizerToggle<CR>", { desc = "Toggle colors"})
