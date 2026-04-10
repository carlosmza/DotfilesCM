return {
    "ibhagwan/fzf-lua",
  -- optional for icon support
  --dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "nvim-mini/mini.icons" },
  cmd = "FzfLua",
  config = function ()
      local fzf = require("fzf-lua")
    fzf.setup({
			fzf_colors = true,
      winopts = {
        height = 0.90,
        width = 1,
        border = "rounded",
      },
      actions = {
        files = {
          ["default"] = fzf.actions.file_edit,       -- abrir archivo normalmente
        },
      },
    })
  end
}
