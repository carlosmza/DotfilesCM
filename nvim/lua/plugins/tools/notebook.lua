return {
  "GCBallesteros/NotebookNavigator.nvim",
	enabled = false,
  config = function()
    require("notebook-navigator").setup {
			repl_provider = "iron",
      -- Aquí puedes definir teclas personalizadas o dejar las predeterminadas
      -- Ejemplo de mapeos:
      mappings = {
        next_cell = "<leader>cn",
        prev_cell = "<leader>cp",
        run_cell = "<leader>nr",
        run_cell_and_next = "<leader>cnr",
        new_cell_after = "<leader>ca",
        new_cell_before = "<leader>cA",
      },
    }

    -- Opcional: autocommand para que solo se active en archivos de notebook o python
    -- vim.api.nvim_create_autocmd("FileType", {
    --   pattern = { "python", "ipynb" },
    --   callback = function()
    --     -- activa el modo de navegación de celdas
    --     require("notebook-navigator").enable()
    --   end,
    -- })
  end,
}
