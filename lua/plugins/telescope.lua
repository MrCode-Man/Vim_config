return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8", -- Versão estável do plugin
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          theme = "dropdown",
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
          },
        },
      })

      local builtin = require("telescope.builtin")

      -- Todo atalho do Telescope começa com <leader>t
      vim.keymap.set("n", "<leader>tf", builtin.find_files, { desc = "Telescope: buscar arquivos" })
      vim.keymap.set("n", "<leader>tg", builtin.live_grep,  { desc = "Telescope: buscar texto" })
      vim.keymap.set("n", "<leader>tb", builtin.buffers,    { desc = "Telescope: listar buffers" })
    end,
  },
}
