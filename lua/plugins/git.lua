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

      -- ATALHOS DE TECLA (Prefixados com <leader>g para Git)

      -- Espaço + g + p (Preview): Mostra uma janela flutuante com o que mudou no bloco atual
      vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Git pré-visualizar alteração" })

      -- Espaço + g + b (Blame): Mostra quem alterou a linha atual e a mensagem do commit
      vim.keymap.set("n", "<leader>gb", gitsigns.blame_line, { desc = "Git autor da linha" })

      -- Espaço + g + s (Stage): Faz o 'git add' apenas do bloco sob o cursor
      vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Git dar add no bloco" })

      -- Espaço + g + r (Reset): Desfaz as alterações apenas do bloco sob o cursor
      vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Git desfazer bloco" })

      -- NAVEGAÇÃO ENTRE ALTERAÇÕES DO CÓDIGO ( ]c e [c )
      -- Pula direto para a próxima alteração ou a anterior no arquivo
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
      -- Espaço + g + d (Diff Open): Abre o painel de diff completo do projeto
      vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git abrir visão de Diff/Conflitos" })

      -- Espaço + g + c (Diff Close): Fecha a janela de diff e volta ao normal
      vim.keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<cr>", { desc = "Git fechar visão de Diff" })
    end,
  },
}
