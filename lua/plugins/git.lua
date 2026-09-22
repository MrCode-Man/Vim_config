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
        current_line_blame = false, -- liga/desliga com <leader>gl
        current_line_blame_opts = {
          delay = 300,
          virt_text_pos = "eol",
        },
      })

      -- Tabela centralizada: todo atalho de Git começa com <leader>g.
      -- Pra adicionar um novo, é só acrescentar uma linha aqui.
      local mapas = {
        -- Blocos de alteração (hunks)
        { "<leader>gp", gitsigns.preview_hunk,    "pré-visualizar bloco alterado" },
        { "<leader>gs", gitsigns.stage_hunk,      "adicionar bloco (stage)" },
        { "<leader>gu", gitsigns.undo_stage_hunk, "desfazer stage do bloco" },
        { "<leader>gr", gitsigns.reset_hunk,      "descartar alteração do bloco" },

        -- Arquivo inteiro (novo: antes só dava pra fazer isso bloco a bloco)
        { "<leader>gS", gitsigns.stage_buffer,    "adicionar o arquivo inteiro" },
        { "<leader>gR", gitsigns.reset_buffer,    "descartar o arquivo inteiro" },
        { "<leader>gD", gitsigns.diffthis,        "ver diff do arquivo com o índice" },

        -- Autoria / histórico
        { "<leader>gb", gitsigns.blame_line,               "ver quem alterou essa linha" },
        { "<leader>gl", gitsigns.toggle_current_line_blame, "alternar blame inline (ligar/desligar)" },

        -- Diffview: visão geral do projeto e conflitos de merge
        { "<leader>gd", "<cmd>DiffviewOpen<cr>",        "abrir visão de Diff/Conflitos" },
        { "<leader>gq", "<cmd>DiffviewClose<cr>",       "fechar visão de Diff" },
        { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", "ver histórico do arquivo atual" },
      }

      for _, mapa in ipairs(mapas) do
        vim.keymap.set("n", mapa[1], mapa[2], { desc = "Git: " .. mapa[3] })
      end

      -- Navegação entre alterações do código ( ]c e [c )
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
            -- Dentro da tela de conflito: qual versão manter
            { "n", "<leader>go", actions.conflict_choose("ours"),   { desc = "Git: escolher nossa versão (ours)" } },
            { "n", "<leader>gt", actions.conflict_choose("theirs"), { desc = "Git: escolher versão recebida (theirs)" } },
            { "n", "<leader>ga", actions.conflict_choose("all"),    { desc = "Git: manter as duas versões" } },
          },
        },
      })
    end,
  },
}
