return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8", -- Versão estável do plugin
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>tf", function() require("telescope.builtin").find_files() end, desc = "Telescope: buscar arquivos" },
      { "<leader>tg", function() require("telescope.builtin").live_grep() end,  desc = "Telescope: buscar texto" },
      { "<leader>tb", function() require("telescope.builtin").buffers() end,    desc = "Telescope: listar buffers" },
    },
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = require("telescope.themes").get_dropdown({
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
          },
        }),
      })
    end,
  },
}
