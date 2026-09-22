return {
  -- 1. GITSIGNS: Sinais laterais, blame e ações por bloco no código
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local gitsigns = require("gitsigns")

      gitsigns.setup({
        signs = {
          add          = { text = "│" },
          change       = { text = "│" },
          delete       = { text = "_" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
        },
      })

      -- ATALHOS DE TECLA DO GITSIGNS (Iniciados com <leader>g)
      vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Git pré-visualizar alteração" })
      vim.keymap.set("n", "<leader>gb", gitsigns.blame_line, { desc = "Git autor da linha" })
      vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Git dar add no bloco" })
      vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Git desfazer bloco" })

      -- NAVEGAÇÃO ENTRE ALTERAÇÕES DO CÓDIGO ( ]c e [c )
      vim.keymap.set("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gitsigns.next_hunk() end)
        return "<Ignore>"
      end, { expr = true, desc = "Ir para próxima alteração Git" })

      vim.keymap.set("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gitsigns.prev_hunk() end)
        return "<Ignore>"
      end, { expr = true, desc = "Ir para alteração Git anterior" })
    end,
  },

  -- 2. DIFFVIEW: Interface gráfica visual para ver Diffs e resolver Conflitos de Merge
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local actions = require("diffview.actions")

      require("diffview").setup({
        keymaps = {
          view = {
            -- Espaço + g + o: Escolher a TUA versão (Esquerda / Ours)
            { "n", "<leader>go", actions.conflict_choose("ours"), { desc = "Git escolher nossa versão (Ours)" } },
            -- Espaço + g + t: Escolher a OUTRA versão (Direita / Theirs)
            { "n", "<leader>gt", actions.conflict_choose("theirs"), { desc = "Git escolher versão recebida (Theirs)" } },
            -- Espaço + g + b: Escolher AMBAS as versões (Both)
            { "n", "<leader>gb", actions.conflict_choose("all"), { desc = "Git manter ambas as versões" } },
          },
        },
      })

      -- Espaço + g + d (Diff Open): Abre o painel de diff completo do projeto
      vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git abrir visão de Diff/Conflitos" })

      -- Espaço + g + q (Diff Quit): Fecha a janela do diff
      vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Git fechar visão de Diff" })
    end,
  },
}
