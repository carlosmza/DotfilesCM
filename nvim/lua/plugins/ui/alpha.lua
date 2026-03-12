return {
{
  "goolord/alpha-nvim",
  lazy = false,
  priority = 900,
  enabled = true,
  dependencies = {'nvim-tree/nvim-web-devicons'},
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    local logo = [[
                                                      
       ███████████           █████      ██
      ███████████             █████ 
      ████████████████ ███████████ ███   ███████
     ████████████████ ████████████ █████ ██████████████
    █████████████████████████████ █████ █████ ████ █████
  ██████████████████████████████████ █████ █████ ████ █████
 ██████  ███ █████████████████ ████ █████ █████ ████ ██████
 ██████   ██  ███████████████   ██ █████████████████
    ]]
    local header_val = vim.split(logo, '\n')
    dashboard.section.header.val = header_val

    dashboard.section.buttons.val = {
      dashboard.button("e",  "   New file", ":ene <CR>"),
      dashboard.button("-",  "   Open files with Fyler", ":Fyler <CR>"),
      dashboard.button("r",  "🖿  Recent files", ":FzfLua oldfiles <CR>"),
      dashboard.button("s0", "   Find sentence (cwd)", ":FzfLua live_grep <CR>"),
			-- dashboard.button("s1", "   Find sentence (home)", ":FzfLua live_grep cwd=/home/carlos/ <CR>"),
      dashboard.button("f0", "󰮗   Find files (cwd)", ":FzfLua files <CR>"),
      -- dashboard.button("f1", "󰮗   Find files (root)", ":FzfLua files cwd=/ <CR>"),
      dashboard.button("q",  "   Quit NVIM", ":qa <CR>"),
    }
    local lazy_stats = require("lazy").stats()
    dashboard.section.footer.val = {
        " 󰒲  Plugins loaded: "
        .. lazy_stats.loaded
        .. " / "
        .. lazy_stats.count
        .. " in "
        .. lazy_stats.startuptime
        .. "ms"
    }

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd([[ autocmd FileType alpha setlocal nofoldenable ]])

    alpha.setup(dashboard.opts)
  end
}

}
