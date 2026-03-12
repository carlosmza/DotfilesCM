return {
  "GCBallesteros/jupytext.nvim",
	enabled = false,
  opts = {
    jupytext_cmd = "jupy-text", -- usa un nombre distinto para evitar conflicto
    format = "py:percent",
    update = true,
    autosync = true,
    sync_patterns = { "*.md", "*.py", "*.ipynb" },
    handle_url_schemes = true,
  },
  config = function(_, opts)
    require("jupytext").setup(opts)
  end,
}

